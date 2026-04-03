class Book < ApplicationRecord
  include InputSanitizable

  belongs_to :author
  has_many :collection_books, dependent: :destroy
  has_many :collections, through: :collection_books

  GENRES = [
    "Fiction", "Non-Fiction", "Science Fiction", "Fantasy", "Mystery",
    "Thriller", "Romance", "Horror", "Biography", "History",
    "Science", "Philosophy", "Self-Help", "Business", "Technology",
    "Poetry", "Children", "Young Adult", "Graphic Novel", "Other"
  ].freeze

  READ_STATUSES = %w[unread reading read].freeze

  VALID_RATINGS = (0..10).map { |i| i * 0.5 }.freeze

  validates :title, presence: true, length: { maximum: 300 }
  validates :isbn, uniqueness: true, allow_nil: true
  validate :isbn_format_and_check_digit
  validates :author, presence: true
  validates :published_year, numericality: { only_integer: true, in: 1000..Date.current.year }, allow_nil: true
  validates :genre, presence: true, inclusion: { in: GENRES }
  validates :description, length: { maximum: 5000 }
  validates :page_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :language, format: { with: /\A[a-z]{2}\z/ }, allow_nil: true
  validates :rating, inclusion: { in: VALID_RATINGS }, allow_nil: true
  validates :read_status, presence: true, inclusion: { in: READ_STATUSES }

  before_validation :set_date_added, on: :create

  scope :by_genre, ->(g) { where(genre: g) }
  scope :by_read_status, ->(s) { where(read_status: s) }
  scope :by_author, ->(id) { where(author_id: id) }
  scope :by_language, ->(l) { where(language: l) }
  scope :by_rating_min, ->(r) { where("rating >= ?", r) }
  scope :by_rating_max, ->(r) { where("rating <= ?", r) }
  scope :by_published_year_min, ->(y) { where("published_year >= ?", y) }
  scope :by_published_year_max, ->(y) { where("published_year <= ?", y) }
  scope :search_text, ->(q) {
    where("title ILIKE :q OR description ILIKE :q", q: "%#{sanitize_sql_like(q)}%")
  }

  private

  def set_date_added
    self.date_added ||= Time.current
  end

  def isbn_format_and_check_digit
    return if isbn.blank?
    unless isbn.match?(/\A\d{13}\z/)
      errors.add(:isbn, "must be exactly 13 digits")
      return
    end
    unless IsbnValidator.valid?(isbn)
      errors.add(:isbn, "has an invalid check digit")
    end
  end
end
