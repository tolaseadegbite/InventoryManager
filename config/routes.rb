Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "items#index"

  resources :categories
  resources :items do
    member do
      post :modify_quantity
      get 'quantity_modal/:action_type', action: :quantity_modal, as: :quantity_modal
    end
  end

  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"
end
