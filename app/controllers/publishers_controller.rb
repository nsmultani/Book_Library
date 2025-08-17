class PublishersController < ApplicationController
  def index
    @publishers = Publisher.includes(:books)
                           .order(:name)
                           .page(params[:page])
                           .per(15)
    @total_publishers = Publisher.count
  end

  def show
    @publisher = Publisher.includes(books: [:authors, :subjects]).find(params[:id])
    @books_count = @publisher.books.count
  end
end