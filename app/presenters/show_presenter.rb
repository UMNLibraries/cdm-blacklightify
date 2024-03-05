# frozen_string_literal: true

class ShowPresenter < Blacklight::ShowPresenter
  def config_type
    arr = { primary: "", phys_desc: "Physical Description", topic: "Topics", geo_loc: "Geographic Location", 
                                                                             coll_info: "Collection Information", 
                                                                             identifiers: "Identifiers", 
                                                                             use: "Can I use It?" }
  end

  def type_arr(type)    # returns boolean if any field in type_arr is present in the document
    type_arr =[]

    configuration.show_fields.to_a.each do |item| 
      if item[1][:type]==type   # sets the field type
        type_arr.push(item[0])
      end
    end

    type_arr.each do |field|   # checks document for field presence
      return document[field].present? 
    end
  end

  def each_field(type)
    fields_to_render do |field_name, field_config, field_presenter|
      yield field_name, field_config, field_presenter if field_config[:type] == type
    end
  end
end
