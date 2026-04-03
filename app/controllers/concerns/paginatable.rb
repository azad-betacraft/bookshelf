module Paginatable
  extend ActiveSupport::Concern

  private

  def paginate(scope)
    p = pagination_params
    paginated = scope.page(p[:page]).per(p[:per_page])
    [ paginated, pagination_meta(paginated) ]
  end

  def pagination_params
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i
    raise ::Errors::BadRequestError, "page must be a positive integer" if page < 1
    raise ::Errors::BadRequestError, "per_page must be between 1 and 100" unless per_page.between?(1, 100)
    { page: page, per_page: per_page }
  end

  def pagination_meta(paginated)
    {
      page: paginated.current_page,
      per_page: paginated.limit_value,
      total_items: paginated.total_count,
      total_pages: paginated.total_pages
    }
  end
end
