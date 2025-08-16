class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name
      t.text :bio
      t.string :birth_date
      t.string :death_date
      t.string :photo_url
      t.string :openlibrary_key

      t.timestamps
    end
  end
end
