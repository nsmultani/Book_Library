class Book < ApplicationRecord
  belongs_to :publisher
  has_many :reviews, dependent: :destroy
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :book_subjects, dependent: :destroy
  has_many :subjects, through: :book_subjects

  validates :title, presence: true
  validates :isbn_10, length: { is: 10 }, allow_blank: true
  validates :isbn_13, length: { is: 13 }, allow_blank: true
  validates :number_of_pages, numericality: { greater_than: 0 }, allow_nil: true

  def average_rating
    reviews.average(:rating)&.round(1)
  end

  def cover_url
    cover_medium_url || cover_small_url
  end
end