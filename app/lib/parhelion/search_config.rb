# frozen_string_literal: true
require 'digest'

module Parhelion
  # Pass around a searh params object instead of a bunch of primitives in the
  # form of search params
  class SearchConfig
    attr_reader :q, :fq, :fl, :page, :rows, :sort
    def initialize(q: '',
                   fq: [],
                   fl: false,
                   rows: 20,
                   page: 1,
                   sort: 'score desc, title desc')
      @q = q
      @fl = fl
      @fq = fq
      @sort = sort
      @rows = rows.to_i
      @page = page.to_i
    end

    def to_h
      option(:q, q)
        .merge(option(:fl, fl))
        .merge(option(:sort, sort))
    end

    # Useful for generating per-search cache keys
    def hash
      Digest::SHA1.hexdigest to_s
    end

    def to_s
      instance_variables.inject do |memo, val|
        "#{memo}#{val}=#{instance_variable_get(val)}"
      end
    end

    private

    def option(key, value)
      !value.blank? ? { key => value } : {}
    end
  end
end
