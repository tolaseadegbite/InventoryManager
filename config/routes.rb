Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root "items#index"

  # Authentication
  resource :session
  resources :passwords, param: :token
  resource :registrations, only: [:new, :create]

  # Others
  resources :categories do
    member do
      get :confirm_delete
    end
  end

  resources :items do
    member do
      get :confirm_delete
    end
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

  # Custom
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"

  get "/settings/", to: "settings#index", as: :settings

  scope "/settings" do
    get "/account", to: "settings#index", as: :account_settings
    get "/account_information", to: "settings#account_information", as: :account_information_settings
    get "/password", to: "settings#password", as: :password_settings
    get "/email", to: "settings#email", as: :email_settings
    patch "/email", to: "settings#update_email", as: :update_email_settings
    get "/name", to: "settings#name", as: :name_settings
    patch "/profile", to: "settings#update_profile", as: :update_profile_settings
    get "/deactivate_account", to: "settings#deactivate_account", as: :deactivate_account_settings

    get "/items", to: "settings#items", as: :items_setting
    get "/items/global_stock_threshold", to: "settings#global_stock_threshold", as: :global_stock_threshold_settings
    patch "/global_stock_threshold", to: "settings#update_global_stock_threshold", as: :update_global_stock_threshold_settings
  end

end
