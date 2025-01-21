Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root "items#index"

  resources :categories

  resources :items do
    member do
      post :modify_quantity
      get 'quantity_modal/:action_type', action: :quantity_modal, as: :quantity_modal
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

  get "/settings/account", to: "settings#index", as: :settings
  get "/settings/account_information", to: "settings#account_information", as: :account_information_settings
  get "/settings/password", to: "settings#password", as: :password_settings
  get "/settings/email", to: "settings#email", as: :email_settings
  get "/settings/name", to: "settings#name", as: :name_settings
  get "/settings/country", to: "settings#country", as: :country_settings
  patch "/settings/profile", to: "settings#update_profile", as: :update_profile_settings
  get "/settings/deactivate_account", to: "settings#deactivate_account", as: :deactivate_account_settings
end
