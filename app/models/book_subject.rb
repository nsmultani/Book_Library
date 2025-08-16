class BookSubject < ApplicationRecord
  belongs_to :book
  belongs_to :subject

  validates :book_id, uniqueness: { scope: :subject_id }
end