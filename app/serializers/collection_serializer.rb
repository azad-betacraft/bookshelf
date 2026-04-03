class CollectionSerializer
  include Alba::Resource

  attributes :id, :name, :description, :is_public, :created_at, :updated_at

  attribute :book_count do |collection|
    collection.respond_to?(:book_count) ? collection.book_count : collection.books.count
  end
end
