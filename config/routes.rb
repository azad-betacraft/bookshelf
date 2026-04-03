Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    resources :authors, only: %i[index show create update destroy] do
      resources :books, only: %i[index], controller: "author_books"
    end

    resources :books, only: %i[index show create update destroy]

    resources :collections, only: %i[index show create update destroy] do
      resources :books, only: %i[create destroy], controller: "collection_books"
      put "books/reorder", to: "collection_books#reorder"
    end

    get "search", to: "search#index"
    get "stats", to: "stats#index"
  end
end
