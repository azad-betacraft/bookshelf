RSpec.shared_examples "a paginated endpoint" do
  it "returns pagination meta" do
    expect(json["meta"]).to include("page", "per_page", "total_items", "total_pages")
  end

  it "returns data as an array" do
    expect(json["data"]).to be_an(Array)
  end
end

RSpec.shared_examples "a not found response" do
  it "returns 404 with NOT_FOUND code" do
    expect(response).to have_http_status(:not_found)
    expect(json["error"]["code"]).to eq("NOT_FOUND")
  end
end

RSpec.shared_examples "a validation error response" do
  it "returns 422 with VALIDATION_ERROR code" do
    expect(response).to have_http_status(:unprocessable_entity)
    expect(json["error"]["code"]).to eq("VALIDATION_ERROR")
    expect(json["error"]["details"]).to be_an(Array)
  end
end
