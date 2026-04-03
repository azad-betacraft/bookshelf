require "rails_helper"

RSpec.describe Author, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:books).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:bio).is_at_most(2000) }

    describe "birth_year" do
      it "allows nil" do
        author = build(:author, birth_year: nil)
        expect(author).to be_valid
      end

      it "must be an integer" do
        author = build(:author, birth_year: 19.5)
        expect(author).not_to be_valid
      end

      it "must be <= current year" do
        author = build(:author, birth_year: Date.current.year + 1)
        expect(author).not_to be_valid
      end

      it "allows current year" do
        author = build(:author, birth_year: Date.current.year)
        expect(author).to be_valid
      end
    end

    describe "death_year" do
      it "allows nil" do
        author = build(:author, death_year: nil)
        expect(author).to be_valid
      end

      it "must be >= birth_year when both present" do
        author = build(:author, birth_year: 1950, death_year: 1940)
        expect(author).not_to be_valid
        expect(author.errors[:death_year]).to include("must be greater than or equal to birth year")
      end

      it "allows death_year equal to birth_year" do
        author = build(:author, birth_year: 1950, death_year: 1950)
        expect(author).to be_valid
      end
    end

    describe "website" do
      it "allows blank" do
        author = build(:author, website: "")
        expect(author).to be_valid
      end

      it "allows valid URLs" do
        author = build(:author, website: "https://example.com")
        expect(author).to be_valid
      end

      it "rejects invalid URLs" do
        author = build(:author, website: "not-a-url")
        expect(author).not_to be_valid
      end
    end
  end

  describe "scopes" do
    describe ".search_by_name" do
      let!(:gabriel) { create(:author, first_name: "Gabriel", last_name: "García Márquez") }
      let!(:jane) { create(:author, first_name: "Jane", last_name: "Austen") }

      it "finds by first name (case-insensitive)" do
        expect(Author.search_by_name("gabriel")).to include(gabriel)
        expect(Author.search_by_name("gabriel")).not_to include(jane)
      end

      it "finds by last name (case-insensitive)" do
        expect(Author.search_by_name("austen")).to include(jane)
      end

      it "finds by partial match" do
        expect(Author.search_by_name("garc")).to include(gabriel)
      end
    end

    describe ".with_book_count" do
      it "includes book_count attribute" do
        author = create(:author)
        create_list(:book, 3, author: author)
        result = Author.with_book_count.find(author.id)
        expect(result.book_count).to eq(3)
      end

      it "returns 0 for authors with no books" do
        author = create(:author)
        result = Author.with_book_count.find(author.id)
        expect(result.book_count).to eq(0)
      end
    end
  end

  describe "InputSanitizable" do
    it "strips HTML tags from string fields" do
      author = create(:author, first_name: "<b>Gabriel</b>", bio: "<script>alert('xss')</script>Bio text")
      expect(author.first_name).to eq("Gabriel")
      expect(author.bio).to eq("alert('xss')Bio text")
    end

    it "trims whitespace from string fields" do
      author = create(:author, first_name: "  Gabriel  ", last_name: "  Márquez  ")
      expect(author.first_name).to eq("Gabriel")
      expect(author.last_name).to eq("Márquez")
    end
  end
end
