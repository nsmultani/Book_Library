class SubjectsController < ApplicationController
  def index
    @subjects = Subject.includes(:books).order(:name)
    @total_subjects = Subject.count
  end

  def show
    @subject = Subject.includes(books: [:authors, :publisher]).find(params[:id])
    @books_count = @subject.books.count
  end
end