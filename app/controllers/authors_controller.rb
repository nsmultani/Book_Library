class AuthorsController < ApplicationController
  def index
    @authors = Author.includes(:books).order(:name)
    @total_authors = Author.count
  end

  def show
    @author = Author.includes(books: [:publisher, :subjects]).find(params[:id])
    @books_count = @author.books.count
  end
end