class PagesController < ApplicationController
  def about
    @total_books = Book.count
    @total_authors = Author.count
    @total_publishers = Publisher.count
    @total_subjects = Subject.count
    @total_reviews = Review.count
    @total_users = User.count
  end
end