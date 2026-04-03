require "rails_helper"

RSpec.describe "Api::Authors", type: :request do
  describe "GET /api/authors" do
    let!(:authors) { create_list(:author, 3) }

    it "returns a paginated list of authors" do
      get "/api/authors"
      expect(response).to have_http_status(:ok)
      expect(json["data"].length).to eq(3)
      expect(json["meta"]).to include("page", "per_page", "total_items", "total_pages")
      expect(json["data"]).to be_an(Array)
    end

    it "includes book_count for each author" do
      create_list(:book, 2, author: authors.first)
      get "/api/authors"
      author_data = json["data"].find { |a| a["id"] == authors.first.id }
      expect(author_data["book_count"]).to eq(2)
    end

    context "pagination" do
      let!(:many_authors) { create_list(:author, 25) }

      it "defaults to page 1 with 20 per_page" do
        get "/api/authors"
        expect(json["data"].length).to eq(20)
        expect(json["meta"]["page"]).to eq(1)
        expect(json["meta"]["per_page"]).to eq(20)
      end

      it "respects custom per_page" do
        get "/api/authors", params: { per_page: 5 }
        expect(json["data"].length).to eq(5)
      end

      it "returns empty data for page beyond total" do
        get "/api/authors", params: { page: 999 }
        expect(json["data"]).to eq([])
      end

      it "returns error for page 0" do
        get "/api/authors", params: { page: 0 }
        expect(response).to have_http_status(:bad_request)
      end

      it "returns error for per_page 0" do
        get "/api/authors", params: { per_page: 0 }
        expect(response).to have_http_status(:bad_request)
      end

      it "returns error for per_page > 100" do
        get "/api/authors", params: { per_page: 101 }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "sorting" do
      let!(:alice) { create(:author, first_name: "Alice", last_name: "Zebra") }
      let!(:bob) { create(:author, first_name: "Bob", last_name: "Adams") }

      it "sorts by last_name asc by default" do
        get "/api/authors"
        last_names = json["data"].map { |a| a["last_name"] }
        expect(last_names).to eq(last_names.sort)
      end

      it "sorts by first_name desc" do
        get "/api/authors", params: { sort_by: "first_name", sort_order: "desc" }
        first_names = json["data"].map { |a| a["first_name"] }
        expect(first_names).to eq(first_names.sort.reverse)
      end

      it "sorts by created_at" do
        get "/api/authors", params: { sort_by: "created_at", sort_order: "desc" }
        expect(response).to have_http_status(:ok)
      end

      it "sorts by book_count" do
        create_list(:book, 3, author: alice)
        get "/api/authors", params: { sort_by: "book_count", sort_order: "desc" }
        expect(json["data"].first["id"]).to eq(alice.id)
      end

      it "rejects invalid sort field" do
        get "/api/authors", params: { sort_by: "invalid" }
        expect(response).to have_http_status(:bad_request)
      end
    end

    context "filtering" do
      let!(:gabriel) { create(:author, first_name: "Gabriel", last_name: "García Márquez") }
      let!(:jane) { create(:author, first_name: "Jane", last_name: "Austen") }

      it "filters by search (partial, case-insensitive)" do
        get "/api/authors", params: { search: "garc" }
        expect(json["data"].length).to eq(1)
        expect(json["data"].first["id"]).to eq(gabriel.id)
      end

      it "returns empty for non-matching search" do
        get "/api/authors", params: { search: "zzzzz" }
        expect(json["data"]).to eq([])
      end
    end
  end

  describe "GET /api/authors/:id" do
    let(:author) { create(:author) }

    it "returns the author with book_count and recent_books" do
      create_list(:book, 7, author: author)
      get "/api/authors/#{author.id}"
      expect(response).to have_http_status(:ok)
      data = json["data"]
      expect(data["id"]).to eq(author.id)
      expect(data["first_name"]).to eq(author.first_name)
      expect(data["book_count"]).to eq(7)
      expect(data["recent_books"].length).to eq(5)
    end

    it "returns 404 for non-existent author" do
      get "/api/authors/999999"
      expect(response).to have_http_status(:not_found)
      expect(json["error"]["code"]).to eq("NOT_FOUND")
    end
  end

  describe "POST /api/authors" do
    let(:valid_params) do
      {
        author: {
          first_name: "Gabriel",
          last_name: "García Márquez",
          bio: "Colombian novelist",
          birth_year: 1927,
          death_year: 2014,
          website: "https://example.com"
        }
      }
    end

    it "creates an author with valid params" do
      post "/api/authors", params: valid_params.to_json, headers: json_headers
      expect(response).to have_http_status(:created)
      data = json["data"]
      expect(data["first_name"]).to eq("Gabriel")
      expect(data["last_name"]).to eq("García Márquez")
      expect(data["book_count"]).to eq(0)
    end

    it "creates an author with only required fields" do
      post "/api/authors",
           params: { author: { first_name: "Jane", last_name: "Austen" } }.to_json,
           headers: json_headers
      expect(response).to have_http_status(:created)
    end

    context "validation errors" do
      it "returns 422 when first_name is missing" do
        post "/api/authors",
             params: { author: { last_name: "Austen" } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["error"]["code"]).to eq("VALIDATION_ERROR")
        fields = json["error"]["details"].map { |d| d["field"] }
        expect(fields).to include("first_name")
      end

      it "returns 422 when last_name is missing" do
        post "/api/authors",
             params: { author: { first_name: "Jane" } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when first_name exceeds 100 characters" do
        post "/api/authors",
             params: { author: { first_name: "a" * 101, last_name: "Test" } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when bio exceeds 2000 characters" do
        post "/api/authors",
             params: { author: { first_name: "J", last_name: "T", bio: "a" * 2001 } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when birth_year is in the future" do
        post "/api/authors",
             params: { author: { first_name: "J", last_name: "T", birth_year: Date.current.year + 1 } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 when death_year < birth_year" do
        post "/api/authors",
             params: { author: { first_name: "J", last_name: "T", birth_year: 1950, death_year: 1940 } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns 422 for invalid website URL" do
        post "/api/authors",
             params: { author: { first_name: "J", last_name: "T", website: "not-a-url" } }.to_json,
             headers: json_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    it "returns 400 without application/json content type" do
      post "/api/authors", params: valid_params.to_json
      expect(response).to have_http_status(:bad_request)
      expect(json["error"]["code"]).to eq("BAD_REQUEST")
    end
  end

  describe "PUT /api/authors/:id" do
    let!(:author) { create(:author, first_name: "Jane", last_name: "Austen") }

    it "updates an author with valid params" do
      put "/api/authors/#{author.id}",
          params: { author: { bio: "English novelist" } }.to_json,
          headers: json_headers
      expect(response).to have_http_status(:ok)
      expect(json["data"]["bio"]).to eq("English novelist")
      expect(json["data"]["first_name"]).to eq("Jane")
    end

    it "supports partial updates" do
      put "/api/authors/#{author.id}",
          params: { author: { first_name: "Janet" } }.to_json,
          headers: json_headers
      expect(response).to have_http_status(:ok)
      expect(json["data"]["first_name"]).to eq("Janet")
      expect(json["data"]["last_name"]).to eq("Austen")
    end

    it "returns 404 for non-existent author" do
      put "/api/authors/999999",
          params: { author: { first_name: "Test" } }.to_json,
          headers: json_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 422 for validation errors" do
      put "/api/authors/#{author.id}",
          params: { author: { first_name: "" } }.to_json,
          headers: json_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 400 without application/json content type" do
      put "/api/authors/#{author.id}", params: { author: { bio: "test" } }.to_json
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "DELETE /api/authors/:id" do
    it "deletes an author with no books" do
      author = create(:author)
      delete "/api/authors/#{author.id}"
      expect(response).to have_http_status(:no_content)
      expect(Author.find_by(id: author.id)).to be_nil
    end

    it "returns 409 DEPENDENCY_EXISTS when author has books" do
      author = create(:author)
      create_list(:book, 3, author: author)
      delete "/api/authors/#{author.id}"
      expect(response).to have_http_status(:conflict)
      expect(json["error"]["code"]).to eq("DEPENDENCY_EXISTS")
      expect(Author.find_by(id: author.id)).to be_present
    end

    it "allows deletion after all books are removed" do
      author = create(:author)
      books = create_list(:book, 2, author: author)
      books.each(&:destroy)
      delete "/api/authors/#{author.id}"
      expect(response).to have_http_status(:no_content)
    end

    it "returns 404 for non-existent author" do
      delete "/api/authors/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /api/authors/:id/books" do
    let(:author) { create(:author) }
    let!(:books) { create_list(:book, 5, author: author) }

    it "returns paginated books for the author" do
      get "/api/authors/#{author.id}/books"
      expect(response).to have_http_status(:ok)
      expect(json["data"].length).to eq(5)
      expect(json["meta"]).to include("page", "per_page", "total_items", "total_pages")
    end

    it "does not include books from other authors" do
      other_author = create(:author)
      create(:book, author: other_author)
      get "/api/authors/#{author.id}/books"
      ids = json["data"].map { |b| b["id"] }
      expect(ids).to match_array(books.map(&:id))
    end

    it "supports sorting" do
      get "/api/authors/#{author.id}/books", params: { sort_by: "title", sort_order: "asc" }
      expect(response).to have_http_status(:ok)
      titles = json["data"].map { |b| b["title"] }
      expect(titles).to eq(titles.sort)
    end

    it "supports pagination" do
      get "/api/authors/#{author.id}/books", params: { per_page: 2, page: 1 }
      expect(json["data"].length).to eq(2)
      expect(json["meta"]["total_items"]).to eq(5)
    end

    it "returns 404 for non-existent author" do
      get "/api/authors/999999/books"
      expect(response).to have_http_status(:not_found)
    end
  end
end
