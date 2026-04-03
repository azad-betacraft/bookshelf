class CollectionPositionManager
  def initialize(collection)
    @collection = collection
  end

  def add_book(book)
    max_position = @collection.collection_books.maximum(:position) || 0
    @collection.collection_books.create!(book: book, position: max_position + 1)
  end

  def remove_book(book)
    cb = @collection.collection_books.find_by!(book: book)
    cb.destroy!
    recalculate_positions
  end

  def reorder(book_ids)
    validate_reorder_set(book_ids)
    ActiveRecord::Base.transaction do
      book_ids.each_with_index do |book_id, index|
        @collection.collection_books
                   .where(book_id: book_id)
                   .update_all(position: index + 1)
      end
    end
  end

  private

  def recalculate_positions
    @collection.collection_books.order(:position).each_with_index do |cb, index|
      cb.update_column(:position, index + 1) if cb.position != index + 1
    end
  end

  def validate_reorder_set(book_ids)
    current_ids = @collection.collection_books.pluck(:book_id).sort
    provided_ids = book_ids.map(&:to_i).sort

    if book_ids.length != book_ids.uniq.length
      raise Errors::BadRequestError, "book_ids must not contain duplicates"
    end

    if provided_ids != current_ids
      raise Errors::BadRequestError, "book_ids must contain exactly the same books currently in the collection"
    end
  end
end
