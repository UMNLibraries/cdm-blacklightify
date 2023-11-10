module IiifHelper
  include Umedia

  def doc_format
    document = @document
    document[:format_name][0] == "Cookbooks" ? "pagingEnabled: false" : "pagingEnabled: true"
  end
end