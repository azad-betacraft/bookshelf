class BookSerializer
  include Alba::Resource

  attributes :id, :title, :isbn, :author_id, :published_year, :genre, :description,
             :page_count, :language, :rating, :read_status, :date_added, :created_at, :updated_at

  attribute :author_name do |book|
    "#{book.author.first_name} #{book.author.last_name}" if book.author
  end
end
