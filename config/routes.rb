Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "items#index"

  resources :categories
  resources :items do
    member do
      post :add_quantity
      post :remove_quantity
    end
  end

  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
end
