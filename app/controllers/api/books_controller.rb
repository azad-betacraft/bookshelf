module Api
  class BooksController < ApplicationController
    include Paginatable
    include Sortable
  end
end
