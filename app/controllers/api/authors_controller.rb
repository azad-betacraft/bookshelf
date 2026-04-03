module Api
  class AuthorsController < ApplicationController
    include Paginatable
    include Sortable

    SORT_FIELDS = %w[last_name first_name created_at book_count].freeze

    def index
      scope = Author.with_book_count
      scope = apply_filters(scope)
      scope = apply_sort(scope, SORT_FIELDS, "last_name")
      authors, meta = paginate(scope)
      render_success(AuthorSerializer.new(authors).to_h, meta: meta)
    end

    def show
      author = Author.with_book_count.find(params[:id])
      render_success(AuthorDetailSerializer.new(author).to_h)
    end

    def create
      author = Author.new(author_params)
      if author.save
        author = Author.with_book_count.find(author.id)
        render_success(AuthorSerializer.new(author).to_h, status: :created)
      else
        render_validation_errors(author)
      end
    end

    def update
      author = Author.find(params[:id])
      if author.update(author_params)
        author = Author.with_book_count.find(author.id)
        render_success(AuthorSerializer.new(author).to_h)
      else
        render_validation_errors(author)
      end
    end

    def destroy
      author = Author.find(params[:id])
      if author.books.exists?
        raise ::Errors::DependencyExistsError,
              "Cannot delete author: #{author.books.count} books are associated with this author"
      end
      author.destroy!
      head :no_content
    end

    private

    def author_params
      params.require(:author).permit(:first_name, :last_name, :bio, :birth_year, :death_year, :website)
    end

    def apply_filters(scope)
      scope = scope.search_by_name(params[:search]) if params[:search].present?
      scope
    end
  end
end
