class SubjectsController < ApplicationController
  def index
    @subjects = Subject.includes(:books).order(:name)
    
    if params[:search].present?
      search_term = params[:search].strip.downcase
      @subjects = @subjects.where("LOWER(name) LIKE ? OR LOWER(description) LIKE ?", 
                                 "%#{search_term}%", "%#{search_term}%")
      @search_performed = true
    end
    
    @total_subjects = @subjects.count
    @subjects = @subjects.page(params[:page]).per(15)
  end

  def show
    @subject = Subject.includes(books: [:authors, :publisher]).find(params[:id])
    @books_count = @subject.books.count
  end
end