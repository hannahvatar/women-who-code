# config/initializers/app_config.rb
module WomenWhoCode  # or whatever your Rails app name is
  module Config
    RETAIL_PRICE = 125.00
    SHIPPING_PRICES = {
      'Standard' => 5.00,
      'Express' => 10.00
    }
  end
end
