# frozen_string_literal: true

require 'addressable/uri'
require 'mimemagic'

module Umedia
  # Umedia::ImageService
  class ImageService
    attr_reader :document, :logger

    def initialize(document)
      @document = document

      @logger ||= ActiveSupport::TaggedLogging.new(
        Logger.new(
          Rails.root.join('log', "image_service_#{Rails.env}.log")
        )
      )
    end

    # Stores the document's image in ActiveStorage
    # @return [Boolean]
    #
    def store!
      # Gentle hands
      sleep(1)

      io_file = image_tempfile(@document.id)

      if io_file.nil?
        log_output({ io_file: io_file.inspect })
      else
        attach_io(io_file)
      end

      log_output({ io_file: io_file })
    rescue StandardError => e
      log_output({ error: e.inspect })
    end

    # Purges the document's image in ActiveStorage
    # @return [Boolean]
    #
    def purge!
      @document.sidecar.image.purge if @document.sidecar.image.attached?
    end

    private

    def image_tempfile(document_id)
      return nil unless image_data

      temp_file = Tempfile.new([document_id, '.tmp'])
      temp_file.binmode
      temp_file.write(image_data)
      temp_file.rewind
      temp_file
    end

    def attach_io(io)
      # Remote content-type headers are untrustworthy
      # Pull the mimetype and file extension via MimeMagic
      mm = MimeMagic.by_magic(File.open(io))

      if mm.mediatype == 'image'
        @document.sidecar.image.attach(
          io: io,
          filename: "#{@document.id}.#{mm.subtype}",
          content_type: mm.type
        )
      else
        @logger.info
      end
    end

    # Generates hash containing thumbnail mime_type and image.
    def image_data
      return nil unless image_url

      remote_image
    end

    # Gets thumbnail image from URL. On error, placehold image.
    def remote_image
      uri = Addressable::URI.parse(image_url)

      return nil unless uri.scheme.include?('http')

      fetch_remote_image(uri)
    rescue StandardError, Faraday::ConnectionFailed
      nil
    end

    def fetch_remote_image(uri)
      conn = Faraday.new(url: uri.normalize.to_s) do |b|
        b.use FaradayMiddleware::FollowRedirects
        b.adapter :net_http
      end

      conn.options.timeout = timeout
      conn.get.body
    end

    # Returns the thumbnail url.
    def image_url
      @image_url ||= @document._source['object_ssi']
    end

    # Faraday timeout value.
    def timeout
      30
    end

    # Capture metadata within image harvest log
    def log_output(hash)
      @logger.tagged(@document.id).info hash.inspect
    end
  end
end
