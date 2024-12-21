class PrintifyService
  include HTTParty
  base_uri 'https://api.printify.com/v1'

  SHOP_ID = '15172090'

  def initialize
    @headers = {
      Authorization: "Bearer #{ENV.fetch('PRINTIFY_API_KEY')}",
      'Content-Type': 'application/json'
    }
  end

  def test_connection
    self.class.get('/shops.json', headers: @headers)
  end

  def products
    self.class.get("/shops/#{SHOP_ID}/products.json", headers: @headers)
  end

  def get_product(product_id)
    self.class.get(
      "/shops/#{SHOP_ID}/products/#{product_id}.json",
      headers: @headers
    )
  end

  def create_order(order_data)
    response = self.class.post(
      "/shops/#{SHOP_ID}/orders.json",
      headers: @headers,
      body: order_data.to_json
    )

    Rails.logger.info "Printify API Response: #{response.body}"
    response
  rescue StandardError => e
    Rails.logger.error "Error creating Printify order: #{e.message}"
    raise
  end

  def publish_product(printify_product_id)
    url = "/shops/#{SHOP_ID}/products/#{printify_product_id}/publish.json"
    publish_data = { variants: true, images: true, title: true, description: true, tags: true }

    response = self.class.post(url, headers: @headers, body: publish_data.to_json)

    if response.success?
      Rails.logger.info "Product #{printify_product_id} published successfully"
      true
    else
      Rails.logger.error "Failed to publish product #{printify_product_id}: #{response.body}"
      false
    end
  end

  def prepare_printify_order(order)
    validate_order(order)
    order_item = order.order_items.first
    product_variant = order_item.product_variant
    product = product_variant.product

    product_data = fetch_product_data(product.printify_id)

    Rails.logger.info "Preparing Printify order for product: #{product.printify_id}"
    Rails.logger.info "Product variant ID: #{product_variant.printify_variant_id}"
    Rails.logger.info "Product data keys: #{product_data.keys}"
    Rails.logger.info "Print providers: #{product_data['print_providers']&.inspect}"

    line_item = prepare_line_item(order_item, product_data, product_variant)

    # Add print areas to the line item
    print_areas = prepare_print_areas(product_data, product_variant)
    line_item[:print_areas] = print_areas

    order_data = {
      external_id: order.id.to_s,
      label: "#{order.first_name} #{order.last_name}",
      line_items: [line_item],
      shipping_method: get_shipping_method(order.shipping_method),
      recipients: [prepare_recipient(order)]
    }

    # Log order data to inspect structure before sending to Printify
    Rails.logger.info "Prepared Printify order data: #{order_data.to_json}"

    order_data
  end

  def send_order_to_printify(order, test_mode: false)
    order_data = prepare_printify_order(order)
    order_data[:test_mode] = test_mode

    response = create_order(order_data)

    if response.success?
      handle_successful_order(order, response)
    else
      handle_failed_order(order, response)
    end
  rescue StandardError => e
    handle_order_error(order, e)
  end

  private

  def validate_order(order)
    raise "Order must have at least one item" if order.order_items.empty?

    required_fields = %i[first_name last_name street_address city postal_code country state]
    missing_fields = required_fields.select { |field| order.send(field).blank? }
    raise "Incomplete shipping information. Missing: #{missing_fields.join(', ')}" unless missing_fields.empty?
  end

  def fetch_product_data(printify_id)
    product_response = get_product(printify_id)
    if product_response.success?
      data = JSON.parse(product_response.body)
      Rails.logger.info "Fetched product data for ID: #{printify_id}"
      Rails.logger.info "Product data keys: #{data.keys}"
      data
    else
      Rails.logger.error "Failed to fetch product data from Printify: #{product_response.body}"
      raise "Failed to fetch product data from Printify. Status: #{product_response.code}, Body: #{product_response.body}"
    end
  end

  def prepare_line_item(order_item, product_data, product_variant)
    Rails.logger.info "Preparing line item with:"
    Rails.logger.info "- Product variant: #{product_variant.attributes}"
    Rails.logger.info "- Product data: #{product_data.slice('id', 'print_provider_id', 'blueprint_id').inspect}"

    unless product_variant.printify_variant_id
      raise "Missing printify_variant_id for product variant #{product_variant.id}"
    end

    {
      print_provider_id: product_data['print_provider_id'],
      blueprint_id: product_data['blueprint_id'],
      variant_id: product_variant.printify_variant_id,
      quantity: order_item.quantity
    }
  end

  def prepare_print_areas(product_data, product_variant)
    Rails.logger.info "Product print areas: #{product_data['print_areas'].inspect}"
    Rails.logger.info "Product variant ID being checked: #{product_variant.printify_variant_id}"

    # Find the first print area
    print_area = product_data['print_areas'].first

    # Prepare a standard print area if exists
    if print_area
      prepared_area = {
        variant_ids: [product_variant.printify_variant_id],
        placeholders: prepare_placeholders(print_area)
      }

      Rails.logger.info "Prepared print area: #{prepared_area.inspect}"
      [prepared_area]
    else
      Rails.logger.warn "No print areas found for the product"
      []
    end
  end

  def prepare_placeholders(area)
    Rails.logger.info "Preparing placeholders for area: #{area.inspect}"
    placeholders = area['placeholders'].map do |placeholder|
      {
        position: placeholder['position'],
        images: prepare_images(placeholder)
      }
    end
    Rails.logger.info "Prepared placeholders: #{placeholders.inspect}"
    placeholders
  end

  def prepare_images(placeholder)
    Rails.logger.info "Preparing images for placeholder: #{placeholder.inspect}"
    images = placeholder['images'].map do |image|
      {
        id: image['id'],
        src: image['src'],
        x: 0.5,
        y: 0.5,
        scale: 1.0,
        angle: 0
      }
    end
    Rails.logger.info "Prepared images: #{images.inspect}"
    images
  end

  def get_shipping_method(method)
    shipping_method_map = { 'Standard' => 1, 'Express' => 2 }
    shipping_method = shipping_method_map[method]
    raise "Invalid shipping method: #{method}" if shipping_method.nil?

    shipping_method
  end

  def prepare_recipient(order)
    {
      name: "#{order.first_name} #{order.last_name}",
      email: order.email,
      phone: order.phone_number,
      address1: order.street_address,
      address2: order.apartment.presence || '',
      city: order.city,
      state: order.state == 'N/A' ? '' : order.state,
      postal_code: order.postal_code,
      country: order.country,
      company: ''
    }
  end

  def handle_successful_order(order, response)
    printify_order_id = JSON.parse(response.body)['id']
    order.update(printify_order_id: printify_order_id, order_status: 'processing')
    { success: true, printify_order_id: printify_order_id }
  end

  def handle_failed_order(order, response)
    error_message = parse_error_message(response)
    order.update(order_status: 'failed')
    order.errors.add(:base, error_message)
    { success: false, error: error_message, details: "Order submission failed" }
  end

  def handle_order_error(order, error)
    Rails.logger.error "Printify Order Error: #{error.message}"
    Rails.logger.error error.backtrace.join("\n")
    order.update(order_status: 'failed', error_message: error.message)
    { success: false, error: error.message, details: "Order preparation failed" }
  end

  def parse_error_message(response)
    JSON.parse(response.body)['error']
  rescue JSON::ParserError
    response.body
  end
end
