Rails.application.routes.draw do
  # Root and main product routes
  root 'products#show'
  resources :products, only: [:show]
  resources :product_variants, only: [:index]

  # Bot routes
  get 'bot', to: 'bot#show'
  post 'bot/ask', to: 'bot#ask'

  # Order and shipping routes
  resources :orders, only: [:new, :create, :show] do
    resources :order_items, only: [:create]
    # Add payment routes nested under orders
    resources :payments, only: [:create]
  end
  get 'calculate_shipping', to: 'orders#calculate_shipping'

  # Stripe & Printify webhooks
  post 'webhooks/stripe', to: 'webhooks#stripe'
  post 'webhooks/printify', to: 'webhooks#printify'
  post 'stripe-webhook', to: 'payments#webhook' # Add Stripe payment webhook

  # Static pages
  get '/terms', to: 'pages#terms', as: :terms
  get '/privacy', to: 'pages#privacy', as: :privacy
  get '/refund', to: 'pages#refund', as: :refund
  get '/shipping', to: 'pages#shipping', as: :shipping
  get '/disclaimer', to: 'pages#disclaimer', as: :disclaimer
  get '/intellectual-property', to: 'pages#intellectual_property', as: :intellectual_property
  get '/contact', to: 'pages#contact', as: :contact
  post '/contact', to: 'pages#create_contact', as: :create_contact
  get '/size-guide', to: 'pages#size_guide', as: :size_guide


  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
 end
