class ProductsController < ApplicationController
  def show
    # If no ID provided (root path), get the first product
    @product = params[:id] ? Product.find(params[:id]) : Product.first

    # Only get variants for our selected colors
    @selected_colors = ['Flo Blue', 'Violet', 'Watermelon', 'Crimson']
    @variants = @product.product_variants
                       .includes(:color, :size)
                       .where(colors: { name: @selected_colors })
                       .group_by(&:color)

    @colors = @product.colors.where(name: @selected_colors).distinct
    @sizes = @product.sizes.distinct.order(:order)
  end
end
