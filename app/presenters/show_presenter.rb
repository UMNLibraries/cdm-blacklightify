# frozen_string_literal: true

class ShowPresenter < Blacklight::ShowPresenter

  def type_arr
    new_arr =[]

    configuration.show_fields.to_a.each do |item| 
      if item[1][:type]==:primary
        new_arr.push(item[0])
      end
    end

    new_arr.each do |field|   # returns boolean if any field in new_arr is present in the document
      return document[field].present? 
    end
  end
  
  def each_primary_field
    fields_to_render do |field_name, field_config, field_presenter|
      yield field_name, field_config, field_presenter if field_config[:type] == :primary
    end
  end

  def each_secondary_field
    fields_to_render.each do |field_name, field_config, field_presenter|
      yield field_name, field_config, field_presenter unless field_config[:type] == :primary
    end
  end

end