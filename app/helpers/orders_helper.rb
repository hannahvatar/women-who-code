# app/helpers/orders_helper.rb
module OrdersHelper
  def calculate_total(variant, quantity)
    # Add logging or debugging
    quantity = (quantity.presence || 1).to_i
    price = variant.product.base_price
    total = price * quantity

    # For debugging
    Rails.logger.debug "Calculating total: #{price} * #{quantity} = #{total}"

    total
  end
end
