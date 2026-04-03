class Collection < ApplicationRecord
  include InputSanitizable

  has_many :collection_books, -> { order(position: :asc) }, dependent: :destroy
  has_many :books, through: :collection_books

  validates :name, presence: true, length: { maximum: 200 }, uniqueness: true
  validates :description, length: { maximum: 1000 }
  validates :is_public, inclusion: { in: [ true, false ] }

  scope :by_public, ->(val) { where(is_public: val == "true") }
  scope :search_text, ->(q) {
    where("name ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(q)}%")
  }
  scope :with_book_count, -> {
    left_joins(:collection_books)
      .select("collections.*, COUNT(collection_books.id) AS book_count")
      .group("collections.id")
  }
end
