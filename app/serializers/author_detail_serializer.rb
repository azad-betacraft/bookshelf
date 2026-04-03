class AuthorDetailSerializer
  include Alba::Resource

  attributes :id, :first_name, :last_name, :bio, :birth_year, :death_year, :website, :created_at, :updated_at

  attribute :book_count do |author|
    author.respond_to?(:book_count) ? author.book_count : author.books.count
  end

  attribute :recent_books do |author|
    books = author.books.order(date_added: :desc).limit(5)
    BookSerializer.new(books).to_h
  end
end
