class SubjectsController < ApplicationController
  def index
    @subjects = Subject.includes(:books).order(:name)
    
    if params[:search].present?
      @subjects = @subjects.where("name LIKE ? OR description LIKE ?", 
                                 "%#{params[:search]}%", "%#{params[:search]}%")
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