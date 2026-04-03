class CreateCollectionBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_books do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: { on_delete: :cascade }
      t.integer :position, null: false
    end

    add_index :collection_books, %i[collection_id book_id], unique: true
    add_index :collection_books, %i[collection_id position]
  end
end
