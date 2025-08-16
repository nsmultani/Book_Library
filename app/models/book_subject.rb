class BookSubject < ApplicationRecord
  belongs_to :book
  belongs_to :subject
end
