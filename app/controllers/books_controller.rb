class BooksController < ApplicationController
  def index
    @books = Book.includes(:authors, :publisher, :subjects)
                 .order(:title)
                 .page(params[:page])
                 .per(12)
    @total_books = Book.count
    
    @subjects = Subject.order(:name)
  end

  def show
    @book = Book.includes(:authors, :publisher, :subjects, :reviews).find(params[:id])
    @average_rating = @book.reviews.average(:rating)&.round(1)
  end

  def search
    @subjects = Subject.order(:name)
    @selected_subject = params[:subject_id].present? ? Subject.find(params[:subject_id]) : nil
    
    if params[:query].present? || params[:subject_id].present?
      @books = Book.includes(:authors, :publisher, :subjects)
      
      if params[:query].present?
        @books = @books.where(
          "title LIKE ? OR EXISTS (SELECT 1 FROM book_authors ba JOIN authors a ON ba.author_id = a.id WHERE ba.book_id = books.id AND a.name LIKE ?)",
          "%#{params[:query]}%", "%#{params[:query]}%"
        )
      end
      
      if params[:subject_id].present?
        @books = @books.joins(:subjects).where(subjects: { id: params[:subject_id] })
      end
      
      @books = @books.order(:title).page(params[:page]).per(12)
      @total_books = @books.count
      @search_performed = true
    else
      redirect_to books_path
    end
    
    render :index
  end
end