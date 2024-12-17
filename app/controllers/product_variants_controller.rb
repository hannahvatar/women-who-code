class ProductVariantsController < ApplicationController
  def index
    # This will be used for AJAX calls to check stock/price
    variant = ProductVariant.find_by(
      product_id: params[:product_id],
      color_id: params[:color_id],
      size_id: params[:size_id]
    )

    render json: {
      price: variant&.price,
      stock: variant&.stock,
      available: variant&.stock.to_i > 0
    }
  end
end
