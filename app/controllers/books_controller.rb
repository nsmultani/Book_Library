class BooksController < ApplicationController
  def index
    @books = Book.includes(:authors, :publisher, :subjects).limit(20)
  end

  def show
    @book = Book.find(params[:id])
  end

  def search
    if params[:query].present?
      @books = Book.where("title LIKE ?", "%#{params[:query]}%").includes(:authors, :publisher)
    else
      @books = Book.all.includes(:authors, :publisher).limit(20)
    end
    render :index
  end
end