module Sortable
  extend ActiveSupport::Concern

  private

  def apply_sort(scope, allowed_fields, default_field)
    s = sort_params(allowed_fields, default_field)
    if s[:field] == "book_count"
      direction = s[:order] == "desc" ? "DESC" : "ASC"
      scope.order(Arel.sql("book_count #{direction}")) # brakeman:ignore
    else
      scope.order(s[:field] => s[:order])
    end
  end

  def sort_params(allowed_fields, default_field)
    field = params[:sort_by]&.to_s || default_field
    order = params[:sort_order]&.downcase || "asc"

    unless allowed_fields.include?(field)
      raise ::Errors::BadRequestError, "Invalid sort field: #{field}. Allowed: #{allowed_fields.join(", ")}"
    end
    unless %w[asc desc].include?(order)
      raise ::Errors::BadRequestError, "sort_order must be 'asc' or 'desc'"
    end

    { field: field, order: order }
  end
end
