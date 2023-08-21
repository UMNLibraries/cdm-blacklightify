# frozen_string_literal: true

class ShowPresenter < Blacklight::ShowPresenter

  def test_field
    arr = [ "type_ssi", "format_ssim", "sp_physical_format_ssi" ]
    # arr = [ "country_ssi", "sp_country_ssi", "continent_ssi", "sp_continent_ssi" ]
    # does the document have anything in the array / check if array contains any or all ? . .
    # document['country_ssi'].present? # just returns true or false
    # arr.include?('continent_ssi')
    # document.include?(document['continent_ssi']) # this does not work. can't access document like an array
    arr.each do |field|
      return document[field].present? # returns boolean if fields in the document are present in the arr array
    end
  end

  def test_arr
    arr = configuration.show_fields.to_a
    new_arr =[]
    arr.each do |item| 
      new_arr.push(item[0])
    end
    new_arr
    # new_arr.each do |field|
    #   return document[field].present? # returns boolean if fields in the document are present in the arr array
    # end
  end

  def type_arr
    arr = configuration.show_fields.to_a
    new_arr =[]
    arr.each do |item| 
      new_arr.push(item[1][:type])
    end
    new_arr
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

  def render_field?(field_config)
    field_presenter(field_config).render_field? and has_value? field_config
  end

end