class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections do |t|
      t.string :name, null: false, limit: 200
      t.text :description
      t.boolean :is_public, null: false, default: false

      t.timestamps
    end

    add_index :collections, :name, unique: true
    add_index :collections, :created_at
  end
end
