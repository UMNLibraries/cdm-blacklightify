# frozen_string_literal: true

class ShowPresenter < Blacklight::ShowPresenter
  def config_type(locale = :en)
    h = {}
    CatalogController.field_types.each do |sect|
      h[sect] = I18n.t("item.field_sections.#{sect.to_s}", locale: locale)
    end
    h
  end

  def type_arr(type)    # returns boolean if any field in field_type_arr is present in the document
    field_type_arr =[]
    configuration.show_fields.to_a.each do |item|
      if item[1][:type] == type   # sets the field type
        field_type_arr.push(item[0])
      end
    end

    field_type_arr.each do |field|   # checks document for field presence
      return true if document[field].present?
    end
    return false
  end

  def each_field(type)
    fields_to_render do |field_name, field_config, field_presenter|
      yield field_name, field_config, field_presenter if field_config[:type] == type
    end
  end
end
