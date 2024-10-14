class UvPresenter
  attr_reader :document
  
  def initialize(document)
    @document = document
  end

  def format_name
    arr = ["Educational events", "Newspapers", "Posters", "Radio programs"]
  end

  def paging_enabled
    format = document[:format_name][0]
    format.in?(format_name) ? "pagingEnabled: false" : "pagingEnabled: true"
  end
end
