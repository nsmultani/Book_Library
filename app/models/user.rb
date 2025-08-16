class User < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :reviewed_books, through: :reviews, source: :book

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end