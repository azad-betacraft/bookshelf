class CollectionDetailSerializer
  include Alba::Resource

  attributes :id, :name, :description, :is_public, :created_at, :updated_at

  attribute :books do |collection|
    collection.collection_books.includes(book: :author).order(:position).map do |cb|
      BookSerializer.new(cb.book).to_h.merge(position: cb.position)
    end
  end
end
