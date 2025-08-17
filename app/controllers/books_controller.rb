class BooksController < ApplicationController
  def index
    @books = Book.includes(:authors, :publisher, :subjects).page(params[:page])
    @total_books = Book.count
  end

  def show
    @book = Book.includes(:authors, :publisher, :subjects, :reviews).find(params[:id])
    @average_rating = @book.reviews.average(:rating)&.round(1)
  end

  def search
    if params[:query].present?
      @books = Book.where("title LIKE ?", "%#{params[:query]}%").includes(:authors, :publisher)
      @total_books = @books.count
    else
      redirect_to books_path
    end
    render :index
  end
end