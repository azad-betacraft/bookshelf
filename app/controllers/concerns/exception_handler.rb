module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ::Errors::ApplicationError do |e|
      render_error(code: e.code, message: e.message, status: e.http_status)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      render_error(code: "NOT_FOUND", message: e.message, status: :not_found)
    end

    rescue_from ActionDispatch::Http::Parameters::ParseError do
      render_error(code: "BAD_REQUEST", message: "Invalid JSON in request body", status: :bad_request)
    end
  end
end
