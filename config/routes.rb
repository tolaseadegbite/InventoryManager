Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root "items#index"

  resources :categories

  resources :items do
    member do
      post :modify_quantity
      get 'quantity_modal/:action_type', action: :quantity_modal, as: :quantity_modal
    end
    collection do
      get :search_modal
    end      
  end

  resources :notifications, only: [:index] do
    member do
      post :mark_read
    end
    collection do
      post :mark_all_read
    end
  end

  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"

  get "/settings/", to: "settings#index", as: :settings
  get "/settings/user", to: "settings#index", as: :user_settings
  get "/settings/user_information", to: "settings#user_information", as: :user_information_settings
  get "/settings/password", to: "settings#password", as: :password_settings
  get "/settings/email", to: "settings#email", as: :email_settings
  get "/settings/name", to: "settings#name", as: :name_settings
  get "/settings/country", to: "settings#country", as: :country_settings
  patch "/settings/profile", to: "settings#update_profile", as: :update_profile_settings
  get "/settings/deactivate_user", to: "settings#deactivate_user", as: :deactivate_user_settings

  get "/settings/items", to: "settings#items", as: :items_settings
end
