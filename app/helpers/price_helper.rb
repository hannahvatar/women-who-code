# app/helpers/price_helper.rb
module PriceHelper
  def format_price(amount)
    number_to_currency(amount, precision: 2)
  end
end
