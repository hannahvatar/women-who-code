Rails.application.routes.draw do
  # Root should go directly to the product show page
  root 'products#show'

  resources :products, only: [:show]
  resources :product_variants, only: [:index]
  resources :orders, only: [:new, :create, :show] do
    resources :order_items, only: [:create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
