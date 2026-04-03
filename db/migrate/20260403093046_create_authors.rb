class CreateAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :authors do |t|
      t.string :first_name, null: false, limit: 100
      t.string :last_name, null: false, limit: 100
      t.text :bio
      t.integer :birth_year
      t.integer :death_year
      t.string :website

      t.timestamps
    end

    add_index :authors, %i[last_name first_name]
    add_index :authors, :created_at
  end
end
