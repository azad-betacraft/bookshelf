module Api
  class AuthorBooksController < ApplicationController
    include Paginatable
    include Sortable

    SORT_FIELDS = %w[title published_year date_added rating page_count].freeze

    def index
      author = Author.find(params[:author_id])
      scope = author.books
      scope = apply_sort(scope, SORT_FIELDS, "date_added")
      books, meta = paginate(scope)
      render_success(BookSerializer.new(books).to_h, meta: meta)
    end
  end
end
