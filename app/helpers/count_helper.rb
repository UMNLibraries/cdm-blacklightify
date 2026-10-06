module CountHelper
  include Umedia

  def item_count
    number_with_delimiter(Umedia::RecordCount.new.item_count,delimiter: ",")
  rescue RSolr::Error::Http, Errno::ECONNREFUSED => e
    "0"
  end

  def page_count
    number_with_delimiter(Umedia::RecordCount.new.page_count,delimiter: ",")
  rescue RSolr::Error::Http, Errno::ECONNREFUSED => e
    "0"
  end

  def collection_count
    Umedia::RecordCount.new.collection_count.length/2
  rescue RSolr::Error::Http, Errno::ECONNREFUSED => e
    0
  end
end
