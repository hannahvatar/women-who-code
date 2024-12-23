Rails.application.routes.draw do
  # Root and main product routes
  root 'products#show'
  resources :products, only: [:show]
  resources :product_variants, only: [:index]

  # Bot routes
  get 'bot', to: 'bot#show'
  post 'bot/ask', to: 'bot#ask'

  # Order routes
  resources :orders, only: [:new, :create, :show] do
    resources :order_items, only: [:create]
    # Add payment routes nested under orders
    resources :payments, only: [:create]
  end

  # Stripe webhook route
  post 'webhooks/stripe', to: 'webhooks#create'

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
