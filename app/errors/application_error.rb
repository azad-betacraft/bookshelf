module Errors
  class ApplicationError < StandardError
    attr_reader :code, :http_status

    def initialize(message = "Something went wrong", code: "INTERNAL_ERROR", http_status: :internal_server_error)
      @code = code
      @http_status = http_status
      super(message)
    end
  end
end
