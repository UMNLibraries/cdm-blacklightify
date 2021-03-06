# frozen_string_literal: true

# This migration comes from spotlight (originally 20151124105543)
class UpdateCustomFieldNames < ActiveRecord::Migration[4.2]
  def up
    fields = {}

    Spotlight::CustomField.find_each do |f|
      f.update(field: f.send(:field_name))
      fields[f.solr_field] = f
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, _v| fields.key? k }.each do |k, _v|
        f.data[fields[k].send(:field_name)] = f.data.delete(k)
      end
    end
  end

  def down
    fields = {}

    Spotlight::CustomField.find_each do |f|
      fields[f.field] = f
      f.update(field: f.send(:solr_field))
    end

    Spotlight::SolrDocumentSidecar.find_each do |f|
      f.data.select { |k, _v| fields.key? k }.each do |k, _v|
        f.data[fields[k].send(:solr_field)] = f.data.delete(k)
      end
    end
  end
end
