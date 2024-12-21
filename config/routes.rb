Rails.application.routes.draw do
  # Root and main product routes
  root 'products#show'
  resources :products, only: [:show]
  resources :product_variants, only: [:index]

  # Bot routes
  get 'bot', to: 'bot#show'
  post 'bot/ask', to: 'bot#ask'  # Changed from get to post since it's handling form submissions

  # Order routes
  resources :orders, only: [:new, :create, :show] do
    resources :order_items, only: [:create]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
