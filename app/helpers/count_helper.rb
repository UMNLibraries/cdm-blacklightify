module CountHelper
  include Umedia

  def item_count
    number_with_delimiter(Umedia::RecordCount.new.item_count,delimiter: ",")
  end

  def page_count
    number_with_delimiter(Umedia::RecordCount.new.page_count,delimiter: ",")
  end

  def collection_count
    Umedia::RecordCount.new.collection_count.length/2
  end
end
