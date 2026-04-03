class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.string :title, null: false, limit: 300
      t.string :isbn, limit: 13
      t.references :author, null: false, foreign_key: true
      t.integer :published_year
      t.string :genre, null: false, limit: 50
      t.text :description
      t.integer :page_count
      t.string :language, limit: 5, default: "en"
      t.decimal :rating, precision: 2, scale: 1
      t.string :read_status, null: false, default: "unread", limit: 10
      t.datetime :date_added, null: false

      t.timestamps
    end

    add_index :books, :isbn, unique: true, where: "isbn IS NOT NULL"
    add_index :books, :genre
    add_index :books, :read_status
    add_index :books, :language
    add_index :books, :rating
    add_index :books, :published_year
    add_index :books, :date_added
    add_index :books, :title
  end
end
