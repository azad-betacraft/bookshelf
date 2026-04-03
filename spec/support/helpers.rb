module RequestHelpers
  def json
    JSON.parse(response.body)
  end

  def json_headers
    { "Content-Type" => "application/json" }
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
end
