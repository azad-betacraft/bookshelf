# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_03_093051) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  create_table "authors", force: :cascade do |t|
    t.text "bio"
    t.integer "birth_year"
    t.datetime "created_at", null: false
    t.integer "death_year"
    t.string "first_name", limit: 100, null: false
    t.string "last_name", limit: 100, null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["created_at"], name: "index_authors_on_created_at"
    t.index ["last_name", "first_name"], name: "index_authors_on_last_name_and_first_name"
  end

  create_table "books", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "date_added", null: false
    t.text "description"
    t.string "genre", limit: 50, null: false
    t.string "isbn", limit: 13
    t.string "language", limit: 5, default: "en"
    t.integer "page_count"
    t.integer "published_year"
    t.decimal "rating", precision: 2, scale: 1
    t.string "read_status", limit: 10, default: "unread", null: false
    t.string "title", limit: 300, null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_books_on_author_id"
    t.index ["date_added"], name: "index_books_on_date_added"
    t.index ["genre"], name: "index_books_on_genre"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true, where: "(isbn IS NOT NULL)"
    t.index ["language"], name: "index_books_on_language"
    t.index ["published_year"], name: "index_books_on_published_year"
    t.index ["rating"], name: "index_books_on_rating"
    t.index ["read_status"], name: "index_books_on_read_status"
    t.index ["title"], name: "index_books_on_title"
  end

  create_table "collection_books", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "collection_id", null: false
    t.integer "position", null: false
    t.index ["book_id"], name: "index_collection_books_on_book_id"
    t.index ["collection_id", "book_id"], name: "index_collection_books_on_collection_id_and_book_id", unique: true
    t.index ["collection_id", "position"], name: "index_collection_books_on_collection_id_and_position"
    t.index ["collection_id"], name: "index_collection_books_on_collection_id"
  end

  create_table "collections", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.boolean "is_public", default: false, null: false
    t.string "name", limit: 200, null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_collections_on_created_at"
    t.index ["name"], name: "index_collections_on_name", unique: true
  end

  add_foreign_key "books", "authors"
  add_foreign_key "collection_books", "books", on_delete: :cascade
  add_foreign_key "collection_books", "collections"
end
