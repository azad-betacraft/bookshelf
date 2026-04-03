module Errors
  class BadRequestError < ApplicationError
    def initialize(message = "Bad request")
      super(message, code: "BAD_REQUEST", http_status: :bad_request)
    end
  end
end
