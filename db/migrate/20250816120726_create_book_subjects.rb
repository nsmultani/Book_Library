class CreateBookSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :book_subjects do |t|
      t.references :book, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true

      t.timestamps
    end
  end
end
