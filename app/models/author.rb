class Author < ApplicationRecord
  has_many :book_authors, dependent: :destroy
  has_many :books, through: :book_authors

  validates :name, presence: true
  validates :openlibrary_key, uniqueness: true, allow_blank: true

  def display_years
    return nil unless birth_date.present?
    if death_date.present?
      "#{birth_date} - #{death_date}"
    else
      "#{birth_date} - present"
    end
  end
end