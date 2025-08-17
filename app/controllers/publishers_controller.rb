class PublishersController < ApplicationController
  def index
    @publishers = Publisher.includes(:books).order(:name)
    
    if params[:search].present?
      search_term = params[:search].strip.downcase
      @publishers = @publishers.where("LOWER(name) LIKE ?", "%#{search_term}%")
      @search_performed = true
    end
    
    @total_publishers = @publishers.count
    @publishers = @publishers.page(params[:page]).per(15)
  end

  def show
    @publisher = Publisher.includes(books: [:authors, :subjects]).find(params[:id])
    @books_count = @publisher.books.count
  end
end