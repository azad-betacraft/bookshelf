class BookDetailSerializer
  include Alba::Resource

  attributes :id, :title, :isbn, :published_year, :genre, :description,
             :page_count, :language, :rating, :read_status, :date_added, :created_at, :updated_at

  one :author, resource: AuthorSerializer
end
