Rails.application.routes.draw do
  root "static_pages#home"
  get "up" => "rails/health#show", as: :rails_health_check
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Authentication
  resource :session
  resources :passwords, param: :token
  resource :registrations, only: [:new, :create]

  # Inventory resources
  resources :inventories do
    member do
      get 'dashboard'
      get :confirm_delete
    end
    
    resources :categories do
      member do
        get :confirm_delete
      end
    end

    resources :items do
      member do
        get :confirm_delete
        post :modify_quantity
        get 'quantity_modal/:action_type', action: :quantity_modal, as: :quantity_modal
      end
      
      collection do
        get :search_modal
      end
    end

    resources :inventory_invitations, only: [:new, :create, :destroy] do
      member do
        get :confirm_delete
      end
    end

    resources :inventory_users do
      member do
        get :confirm_delete
      end
      resource :permission, controller: 'inventory_user_permissions'
    end
  end

  resources :inventory_invitations, only: [] do
    member do
      post :accept
      post :decline
    end
  end

  # User management
  resources :users do
    member do
      get :confirm_delete
    end
  end

  # Notifications
  resources :notifications, only: [:index, :show] do
    member do
      post :mark_read
      get :show
    end
    collection do
      post :mark_all_read
    end
  end

  # Authentication routes
  get '/sign_in', to: 'sessions#new'
  get '/sign_up', to: 'registrations#new'

  # Static pages
  get "/home", to: "static_pages#help"
  get "/help", to: "static_pages#help"
  get "/about", to: "static_pages#about"

  # Settings routes
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