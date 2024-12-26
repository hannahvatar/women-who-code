class ProductVariantsController < ApplicationController
  def index
    # Log the request details
    Rails.logger.info "Request details:"
    Rails.logger.info "  Parameters: #{params.inspect}"
    Rails.logger.info "  Accept header: #{request.headers['Accept']}"
    Rails.logger.info "  X-Requested-With: #{request.headers['X-Requested-With']}"

    # Always respond with JSON
    response.content_type = 'application/json'

    # Your existing logic...
    if params[:product_id].blank? || params[:color_id].blank? || params[:size_id].blank?
      render json: { error: 'Missing parameters' }, status: :bad_request
      return
    end

    variant = ProductVariant.find_by(
      product_id: params[:product_id],
      color_id: params[:color_id],
      size_id: params[:size_id]
    )

    Rails.logger.info "Found variant: #{variant.inspect}"

    if variant
      render json: {
        id: variant.id,
        color_name: variant.color.name,
        size_name: variant.size.name,
        price: variant.price,
        stock: variant.stock,
        available: variant.stock.to_i > 0
      }
    else
      render json: {
        error: 'No variant found',
        product_id: params[:product_id],
        color_id: params[:color_id],
        size_id: params[:size_id]
      }, status: :not_found
    end
  end
end
