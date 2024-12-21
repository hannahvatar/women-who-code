Rails.application.routes.draw do
  # Route for the AI bot to handle questions
  get 'bot/ask', to: 'bot#ask'

  # Root route should go directly to the product show page
  root 'products#show'

  # Resources for products and variants
  resources :products, only: [:show]
  resources :product_variants, only: [:index]

  # Order-related routes
  resources :orders, only: [:new, :create, :show] do
    resources :order_items, only: [:create]
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
