Rails.application.routes.draw do
  get 'orders/new'
  get 'orders/create'
  get 'orders/show'
  get 'product_variants/index'
  get 'products/show'
  # Change root from pages#home to products#show since
  # we want to display our product directly
  root 'products#show'

  # Product routes - minimal since we only have one product
  resource :product, only: [:show]

  # Product variants - for handling color/size selection
  resources :product_variants, only: [:index]

  # Orders and order items
  resources :orders, only: [:new, :create, :show] do
    resources :order_items, only: [:create]
  end

  # Keep the health check route
  get "up" => "rails/health#show", as: :rails_health_check
end
