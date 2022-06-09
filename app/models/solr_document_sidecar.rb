# frozen_string_literal: true

##
# Metadata for indexed documents
class SolrDocumentSidecar < ApplicationRecord
  belongs_to :document, optional: false, polymorphic: true
  has_one_attached :image

  def document
    document_type.new document_type.unique_key => document_id
  end

  def document_type
    (super.constantize if defined?(super)) || default_document_type
  end

  def image_url
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  def reimage!
    image.purge if image.attached?
    Umedia::StoreImageJob.perform_later(document.id)
  end

  # Exhibits requires public flag
  def public?
    true
  end
end
