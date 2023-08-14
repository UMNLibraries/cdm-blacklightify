# frozen_string_literal: true

class ShowPresenter < Blacklight::ShowPresenter

  def primary_fields
    fields_to_render do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :primary
    end
  end

  def physical_description_fields
    fields_to_render.each do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :phys_desc
    end
  end

  def topic_fields
    fields_to_render.each do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :topic
    end
  end

  def geographic_location_fields
    fields_to_render.each do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :geo_loc
    end
  end

  def collection_information_fields
    fields_to_render.each do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :coll_info
    end
  end
  
  def identifier_fields
    fields_to_render.each do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :identifiers
    end
  end

  def use_field
    fields_to_render.each do |field_name, field_config, field_presenter|
      field_presenter.except_operations << Blacklight::Rendering::Join
      yield field_name, field_config, field_presenter if field_config[:type] == :use
    end
  end

  def render_field?(field_config)
    field_presenter(field_config).render_field? and has_value? field_config
  end

end