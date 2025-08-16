class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :title
      t.string :isbn_10
      t.string :isbn_13
      t.text :description
      t.integer :number_of_pages
      t.string :publish_date
      t.string :cover_small_url
      t.string :cover_medium_url
      t.string :cover_large_url
      t.string :language
      t.references :publisher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
