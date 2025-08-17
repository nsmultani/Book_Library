# config/routes.rb
Rails.application.routes.draw do
  get "subjects/index"
  get "subjects/show"
  get "publishers/index"
  get "publishers/show"
  get "authors/index"
  get "authors/show"
  get "books/index"
  get "books/show"
  get "books/search"
  get "pages/about"
  root 'books#index'
  
  get 'about', to: 'pages#about'
  
  resources :books, only: [:index, :show] do
    collection do
      get :search
    end
  end
  
  resources :authors, only: [:index, :show]
  resources :publishers, only: [:index, :show]
  resources :subjects, only: [:index, :show]
end