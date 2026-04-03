class ApplicationController < ActionController::API
  include ApiResponse
  include ExceptionHandler

  before_action :enforce_json_content_type, if: -> { request.post? || request.put? || request.patch? }

  private

  def enforce_json_content_type
    return if request.content_type&.include?("application/json")
    render_error(
      code: "BAD_REQUEST",
      message: "Content-Type must be application/json",
      status: :bad_request
    )
  end
end
