module Api
  class CollectionsController < ApplicationController
    include Paginatable
    include Sortable
  end
end
