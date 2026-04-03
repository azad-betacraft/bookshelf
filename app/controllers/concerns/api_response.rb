module ApiResponse
  extend ActiveSupport::Concern

  def render_success(data, status: :ok, meta: nil)
    body = { data: data }
    body[:meta] = meta if meta
    render json: body, status: status
  end

  def render_error(code:, message:, status:, details: nil)
    body = { error: { code: code, message: message } }
    body[:error][:details] = details if details
    render json: body, status: status
  end

  def render_validation_errors(record)
    details = record.errors.map { |e| { field: e.attribute.to_s, message: e.message } }
    render_error(code: "VALIDATION_ERROR", message: "Validation failed", status: :unprocessable_entity, details: details)
  end
end
