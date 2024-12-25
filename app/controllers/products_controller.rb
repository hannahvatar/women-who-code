class ProductsController < ApplicationController
  def show
    # Get the product either from the params or default to the first product
    @product = params[:id] ? Product.find_by(id: params[:id]) : Product.first

    # Redirect to root path with alert if no product is found
    unless @product
      redirect_to root_path, alert: "Product not found" and return
    end

    # Only get variants for the selected colors and eager load associations
    @selected_colors = ['Flo Blue', 'Violet', 'Watermelon', 'Crimson']
    @variants = @product.product_variants
                        .joins(:color)
                        .where(colors: { name: @selected_colors })
                        .includes(:color, :size)
                        .group_by(&:color)

    # Get the distinct colors and sizes for the product
    @colors = @product.colors.where(name: @selected_colors).distinct
    @sizes = @product.sizes.distinct.order(:order)
  end
end
