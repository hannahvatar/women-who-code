class ProductsController < ApplicationController
  def show
    # Since we only have one product, we can find the first one
    @product = Product.first
    # Get all variants grouped by color
    @variants = @product.product_variants.includes(:color, :size).group_by(&:color)
    # Get all available colors and sizes
    @colors = @product.colors.distinct
    @sizes = @product.sizes.distinct
  end
end
