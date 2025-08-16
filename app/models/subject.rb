class Subject < ApplicationRecord
  has_many :book_subjects, dependent: :destroy
  has_many :books, through: :book_subjects

  validates :name, presence: true, uniqueness: true
  validates :difficulty_level, inclusion: { in: %w[Beginner Intermediate Advanced Expert] }
end