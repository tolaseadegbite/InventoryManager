Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "static_pages#home"

  resources :categories

  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
end
