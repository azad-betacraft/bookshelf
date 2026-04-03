class Author < ApplicationRecord
  include InputSanitizable

  has_many :books, dependent: :restrict_with_error

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :bio, length: { maximum: 2000 }
  validates :birth_year, numericality: { only_integer: true, less_than_or_equal_to: ->(_) { Date.current.year } }, allow_nil: true
  validates :death_year, numericality: { only_integer: true }, allow_nil: true
  validate :death_year_after_birth_year
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true

  scope :search_by_name, ->(query) {
    where("first_name ILIKE :q OR last_name ILIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

  scope :with_book_count, -> {
    left_joins(:books)
      .select("authors.*, COUNT(books.id) AS book_count")
      .group("authors.id")
  }

  private

  def death_year_after_birth_year
    return unless birth_year && death_year
    errors.add(:death_year, "must be greater than or equal to birth year") if death_year < birth_year
  end
end
