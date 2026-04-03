module Errors
  class DependencyExistsError < ApplicationError
    def initialize(message = "Cannot delete: dependent records exist")
      super(message, code: "DEPENDENCY_EXISTS", http_status: :conflict)
    end
  end
end
