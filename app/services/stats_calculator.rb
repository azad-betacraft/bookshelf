class StatsCalculator
  def call
    {
      total_books: Book.count,
      total_authors: Author.count,
      total_collections: Collection.count,
      books_by_status: books_by_status,
      books_by_genre: books_by_genre,
      books_by_year: books_by_year,
      top_authors: top_authors,
      average_rating: average_rating,
      total_pages: Book.sum(:page_count).to_i,
      average_pages_per_book: average_pages,
      language_distribution: language_distribution
    }
  end

  private

  def books_by_status
    counts = Book.group(:read_status).count
    { read: counts["read"] || 0, reading: counts["reading"] || 0, unread: counts["unread"] || 0 }
  end

  def books_by_genre
    Book.group(:genre).count
        .sort_by { |_, count| -count }
        .map { |genre, count| { genre: genre, count: count } }
  end

  def books_by_year
    cutoff = Date.current.year - 9
    Book.where("published_year >= ?", cutoff)
        .group(:published_year).count
        .sort_by { |year, _| -year }
        .map { |year, count| { year: year, count: count } }
  end

  def top_authors
    Author.left_joins(:books)
          .select("authors.id, authors.first_name, authors.last_name, COUNT(books.id) AS book_count")
          .group("authors.id")
          .order("book_count DESC")
          .limit(10)
          .map { |a| { author_id: a.id, author_name: "#{a.first_name} #{a.last_name}", book_count: a.book_count } }
  end

  def average_rating
    avg = Book.where.not(rating: nil).average(:rating)
    avg ? avg.round(1).to_f : 0.0
  end

  def average_pages
    avg = Book.where.not(page_count: nil).average(:page_count)
    avg ? avg.round.to_i : 0
  end

  def language_distribution
    Book.group(:language).count
        .sort_by { |_, count| -count }
        .map { |lang, count| { language: lang, count: count } }
  end
end
