module Errors
  class ConflictError < ApplicationError
    def initialize(message = "Conflict")
      super(message, code: "CONFLICT", http_status: :conflict)
    end
  end
end
