# static pages controller
class PagesController < ApplicationController
  def index
  end
  
  def about
  end

  def contact
  end

  # Lightweight admin/debug endpoint for querying Spotlight category rows
  # by title/slug using q from the URL.
  def spotlight_db_search
    @query = params[:q].to_s.strip
    @results = []

    return if @query.blank?

    # Escape wildcard characters so LIKE behaves as expected and remains safe.
    escaped_query = ActiveRecord::Base.sanitize_sql_like(@query)
    @results = Spotlight::Search
      .includes(:exhibit)
      .where('spotlight_searches.title LIKE :q OR spotlight_searches.slug LIKE :q', q: "%#{escaped_query}%")
      .order(updated_at: :desc)
      # Keep response fast and predictable.
      .limit(50)
  end
end
