class ProductsController < ApplicationController
  def show
    @product = Product.first
    @variants = @product.product_variants.includes(:color, :size).group_by(&:color)

    @colors = @product.colors.distinct
    @sizes = @product.sizes.distinct.order(:order)
  end
end
