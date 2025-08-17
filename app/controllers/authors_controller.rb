class AuthorsController < ApplicationController
  def index
    @authors = Author.includes(:books).order(:name)
    
    if params[:search].present?
      search_term = params[:search].strip.downcase
      @authors = @authors.where("LOWER(name) LIKE ?", "%#{search_term}%")
      @search_performed = true
    end
    
    @total_authors = @authors.count
    @authors = @authors.page(params[:page]).per(15)
  end

  def show
    @author = Author.includes(books: [:publisher, :subjects]).find(params[:id])
    @books_count = @author.books.count
  end
end