# config/initializers/prices.rb
module YourApp
  class Config
    RETAIL_PRICE = 125.00
    SHIPPING_PRICES = {
      'Standard' => 5.00,
      'Express' => 10.00
    }
  end
end
