module Errors
  class NotFoundError < ApplicationError
    def initialize(message = "Resource not found")
      super(message, code: "NOT_FOUND", http_status: :not_found)
    end
  end
end
