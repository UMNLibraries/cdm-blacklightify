# test/support/rails_cache_helper.rb:
module RailsCacheHelper
  def with_clean_caching
    Rails.cache.clear
    yield

  ensure
    Rails.cache.clear
  end

  def cache_has_value?(value)
    cache_data.values.map(&:value).any?(value)
  end

  def key_for_cached_value(value)
    cache_data.values.each do |key, entry|
      return key if entry&.value == value
    end
  end

  private

  def cache_data
    Rails.cache.instance_variable_get(:@data)
  end
end