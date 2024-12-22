class PrintifyService
  include HTTParty
  base_uri 'https://api.printify.com/v1'

  SHOP_ID = ENV.fetch('PRINTIFY_SHOP_ID', '15172090')
  TIMEOUT = 30 # seconds

  def initialize
    @headers = {
      Authorization: "Bearer #{ENV.fetch('PRINTIFY_API_KEY')}",
      'Content-Type': 'application/json'
    }
  end

  def self.test_connection
    service = new
    response = service.test_connection

    if response.success?
      Rails.logger.info "Printify API Connection Successful"
      true
    else
      Rails.logger.error "Printify API Connection Failed"
      Rails.logger.error "Response: #{response.body}"
      false
    end
  end

  def test_connection
    self.class.get('/shops.json', headers: @headers, timeout: TIMEOUT)
  end

  def products
    self.class.get("/shops/#{SHOP_ID}/products.json", headers: @headers, timeout: TIMEOUT)
  end

  def get_product(product_id)
    self.class.get(
      "/shops/#{SHOP_ID}/products/#{product_id}.json",
      headers: @headers,
      timeout: TIMEOUT
    )
  end

  def create_order(order_data)
    response = self.class.post(
      "/shops/#{SHOP_ID}/orders.json",
      headers: @headers,
      body: order_data.to_json,
      timeout: TIMEOUT
    )

    # Comprehensive logging
    Rails.logger.info "Printify Create Order Request:"
    Rails.logger.info "Request Body: #{order_data.to_json}"
    Rails.logger.info "Response Status: #{response.code}"
    Rails.logger.info "Response Body: #{response.body}"

    # Explicit error handling for non-successful responses
    unless response.success?
      error_details = begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        { 'error' => response.body }
      end

      error_message = error_details['error'] || 'Unknown Printify API error'
      Rails.logger.error "Printify Order Creation Error: #{error_message}"

      raise PrintifyOrderError.new(
        message: error_message,
        status_code: response.code,
        response_body: response.body
      )
    end

    response
  rescue StandardError => e
    Rails.logger.error "Error creating Printify order: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  def prepare_printify_order(order)
    order_items = order.order_items.map do |item|
      line_item = prepare_line_item(item)
      Rails.logger.info "Prepared line item: #{line_item.inspect}"  # Add this debug line
      line_item
    end

    data = {
      external_id: order.id.to_s,
      shipping_method: get_shipping_method(order.shipping_method),
      shipping_address: {
        first_name: order.first_name,
        last_name: order.last_name,
        email: order.email,
        phone: order.phone_number,
        address1: order.street_address,
        address2: order.apartment,
        city: order.city,
        state: order.state,
        country: order.country,
        zip: order.postal_code
      },
      line_items: order_items
    }

    Rails.logger.info "Final order data: #{data.inspect}"  # Add this debug line
    data
  end

  def send_order_to_printify(order, test_mode: false)
    # Extensive logging for debugging
    Rails.logger.info "Sending Order to Printify:"
    Rails.logger.info "Order ID: #{order.id}"
    Rails.logger.info "Test Mode: #{test_mode}"

    begin
      # Prepare order data with comprehensive validation
      order_data = prepare_printify_order(order)
      order_data[:test_mode] = test_mode

      # Log full order data for debugging
      Rails.logger.info "Full Printify Order Data: #{order_data.to_json}"

      # Send order to Printify
      response = create_order(order_data)

      # Handle successful or failed order
      if response.success?
        handle_successful_order(order, response)
      else
        handle_failed_order(order, response)
      end
    rescue PrintifyOrderError => e
      # Handle specific Printify API errors
      Rails.logger.error "Printify Order Submission Error:"
      Rails.logger.error "Message: #{e.message}"
      Rails.logger.error "Status Code: #{e.status_code}"
      Rails.logger.error "Response Body: #{e.response_body}"

      handle_order_error(order, e)
    rescue StandardError => e
      # Catch-all for unexpected errors
      Rails.logger.error "Unexpected Printify Order Error:"
      Rails.logger.error "Message: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.join("\n")}"

      handle_order_error(order, e)
    end
  end

  def prepare_recipient(order)
    {
      name: "#{order.first_name} #{order.last_name}".strip,
      email: order.email.presence || raise("Email is required"),
      phone: order.phone_number.to_s,
      address1: order.street_address.presence || raise("Street address is required"),
      address2: order.apartment.to_s,
      city: order.city.presence || raise("City is required"),
      state: order.state.to_s,
      postal_code: order.postal_code.presence || raise("Postal code is required"),
      country: order.country.presence || raise("Country is required"),
      company: '' # Always provide an empty string for company
    }
  rescue => e
    Rails.logger.error "Error preparing recipient: #{e.message}"
    raise "Invalid recipient information: #{e.message}"
  end


  private

  def validate_order(order)
    raise "Order must have at least one item" if order.order_items.empty?

    required_fields = %i[first_name last_name street_address city postal_code country]
    missing_fields = required_fields.select { |field| order.send(field).blank? }

    raise "Incomplete shipping information. Missing: #{missing_fields.join(', ')}" unless missing_fields.empty?
  end

  def fetch_product_data(printify_id)
    product_response = get_product(printify_id)

    if product_response.success?
      data = JSON.parse(product_response.body)

      # Validate product data
      validate_product_data(data)

      data
    else
      Rails.logger.error "Failed to fetch product data from Printify"
      Rails.logger.error "Status: #{product_response.code}"
      Rails.logger.error "Body: #{product_response.body}"

      raise "Failed to fetch product data. Status: #{product_response.code}"
    end
  end

  # app/services/printify_service.rb
  def fetch_product_variants(product_id)
    response = self.class.get(
      "/shops/#{SHOP_ID}/products/#{product_id}.json",
      headers: @headers,
      timeout: TIMEOUT
    )

    if response.success?
      data = JSON.parse(response.body)

      # Extract variants from the product data
      data['variants'].map do |variant|
        {
          'id' => variant['id'],
          'color' => variant['color'],
          'size' => variant['size'],
          'title' => variant['title'],
          'price' => variant['price']
        }
      end
    else
      Rails.logger.error "Failed to fetch product variants from Printify"
      Rails.logger.error "Status: #{response.code}"
      Rails.logger.error "Body: #{response.body}"
      raise "Failed to fetch product variants. Status: #{response.code}"
    end
  rescue JSON::ParserError => e
    Rails.logger.error "Error parsing Printify response: #{e.message}"
    raise "Invalid response format from Printify API"
  rescue StandardError => e
    Rails.logger.error "Error in fetch_product_variants: #{e.message}"
    raise
  end

  def validate_product_data(product_data)
    required_keys = ['print_provider_id', 'blueprint_id', 'variants', 'print_areas']
    missing_keys = required_keys.select { |key| product_data[key].nil? }

    raise "Missing required product data keys: #{missing_keys.join(', ')}" unless missing_keys.empty?
  end

  def upload_image(image_url)
    response = self.class.post(
      "/shops/#{SHOP_ID}/uploads/images.json",
      headers: @headers,
      body: { file_url: image_url }.to_json,
      timeout: TIMEOUT
    )

    unless response.success?
      raise PrintifyOrderError.new(
        message: "Failed to upload image",
        status_code: response.code,
        response_body: response.body
      )
    end

    JSON.parse(response.body)['id']
  end

  def prepare_line_item(order_item)
    product_variant = order_item.product_variant
    begin
      printify_variant_id = validate_product_variant(product_variant)
      printify_variant_id_str = printify_variant_id.to_s

      # Assuming each color has a unique image URL
      color_images = {
        "violet" => "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg",
        "crimson" => "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg",
        "watermelon" => "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg",
        "flo_blue" => "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
      }

      # Create an array of image objects for each color variant
      images = color_images.map do |color, image_url|
        {
          src: image_url,  # Cloudinary image URL
          variant_ids: [printify_variant_id_str],  # Use the variant ID from Printify
          position: "front",  # Image position on the mockup (could be 'front' or 'back')
          is_default: true,  # You can change this based on whether the image should be default
          is_selected_for_publishing: true,  # Image selected for publishing
          order: nil,  # Order field (if needed, otherwise set to nil)
          scale: 1,  # Image scale (default is 1)
          x: 0,  # X-coordinate for positioning (default is 0)
          y: 0,  # Y-coordinate for positioning (default is 0)
          angle: 0  # Angle for rotation (default is 0)
        }
      end

      # Adding the required 'print_areas' attribute
      print_areas = [
        {
          area: "front",  # Design placement (can also use "back" if applicable)
          images: images
        }
      ]

      # Return the final line item with all image details
      {
        variant_id: printify_variant_id_str,
        quantity: order_item.quantity,
        print_provider_id: 99,  # Your print provider ID
        blueprint_id: 1296,  # Your blueprint ID
        print_areas: print_areas,  # Add the print_areas attribute
        images: images  # Array of image objects
      }
    rescue => e
      Rails.logger.error "Error in prepare_line_item: #{e.message}"
      Rails.logger.error e.backtrace.first(5).join("\n")
      raise
    end
  end



  def fetch_available_variants(printify_id)
    product_response = get_product(printify_id)

    if product_response.success?
      product_data = JSON.parse(product_response.body)

      # Extract and map variants
      product_data['variants'].map do |variant|
        {
          'id' => variant['id'],
          'color' => variant['color']
        }
      end
    else
      Rails.logger.error "Failed to fetch product variants"
      raise "Could not fetch product variants"
    end
  end

  def validate_product_variant(product_variant)
    # Fetch the color and size associated with this variant
    color_name = product_variant.color.name
    size_name = product_variant.size.name

    # Precise mapping for Printify color and size names
    color_mapping = {
      'Blue' => 'Flo Blue',
      'Purple' => 'Violet',
      'Coral' => 'Watermelon',
      'Crimson' => 'Crimson'
    }

    # Printify sizes mapping
    size_mapping = {
      'S' => 'S',
      'M' => 'M',
      'L' => 'L',
      'XL' => 'XL',
      '2XL' => '2XL',
      '3XL' => '3XL'
    }

    # Find the corresponding Printify color name
    printify_color = color_mapping[color_name] || color_name
    printify_size = size_mapping[size_name] || size_name

    # Predefined mappings from Printify
    printify_mappings = {
      ['Flo Blue', 'S'] => 96869,
      ['Flo Blue', 'M'] => 96870,
      ['Flo Blue', 'L'] => 96871,
      ['Flo Blue', 'XL'] => 96872,
      ['Flo Blue', '2XL'] => 96873,
      ['Flo Blue', '3XL'] => 102366,
      ['Violet', 'S'] => 96909,
      ['Violet', 'M'] => 96910,
      ['Violet', 'L'] => 96911,
      ['Violet', 'XL'] => 96912,
      ['Violet', '2XL'] => 96913,
      ['Violet', '3XL'] => 102374,
      ['Watermelon', 'S'] => 96914,
      ['Watermelon', 'M'] => 96915,
      ['Watermelon', 'L'] => 96916,
      ['Watermelon', 'XL'] => 96917,
      ['Watermelon', '2XL'] => 96918,
      ['Watermelon', '3XL'] => 102375,
      ['Crimson', 'S'] => 96859,
      ['Crimson', 'M'] => 96860,
      ['Crimson', 'L'] => 96861,
      ['Crimson', 'XL'] => 96862,
      ['Crimson', '2XL'] => 96863,
      ['Crimson', '3XL'] => 102364
    }

    # Log debugging information
    Rails.logger.info "Local Color Name: #{color_name}"
    Rails.logger.info "Mapped Printify Color: #{printify_color}"
    Rails.logger.info "Local Size Name: #{size_name}"
    Rails.logger.info "Mapped Printify Size: #{printify_size}"

    # Find the Printify variant ID based on color and size
    printify_variant_id = printify_mappings[[printify_color, printify_size]]

    # Check if a variant was found
    if printify_variant_id
      Rails.logger.info "Selected Variant ID: #{printify_variant_id}"
      printify_variant_id
    else
      Rails.logger.error "No valid Printify variant found for color: #{printify_color}, size: #{printify_size}"
      raise "No valid Printify variant found for color: #{color_name}, size: #{size_name}"
    end
  end

  def prepare_print_areas(product_data, product_variant)
    print_areas = product_data['print_areas']

    raise "No print areas found for product" if print_areas.blank?

    # Log the full print areas data for debugging
    Rails.logger.info "Full Print Areas Data: #{print_areas.inspect}"

    processed_areas = print_areas.map do |area|
      begin
        {
          # Use all variant IDs from the print area
          variant_ids: area['variant_ids'] || [],
          placeholders: (area['placeholders'] || []).map do |placeholder|
            {
              position: placeholder['position'],
              images: placeholder['images'] || []
            }
          end
        }
      rescue => e
        Rails.logger.error "Error processing print area:"
        Rails.logger.error "Error Message: #{e.message}"
        Rails.logger.error "Backtrace: #{e.backtrace.first(3).join("\n")}"
        nil
      end
    end.compact

    raise "No valid print areas could be processed" if processed_areas.empty?

    processed_areas
  end

  def get_shipping_method(method)
    shipping_method_map = {
      'Standard' => 1,
      'Express' => 2,
      'Economy' => 3  # Add more methods as needed
    }

    shipping_method = shipping_method_map[method]
    raise "Invalid shipping method: #{method}" if shipping_method.nil?

    shipping_method
  end

  def handle_successful_order(order, response)
    begin
      printify_order_details = JSON.parse(response.body)
      printify_order_id = printify_order_details['id']

      order.update(
        printify_order_id: printify_order_id,
        order_status: 'processing',
        printify_order_details: printify_order_details
      )

      {
        success: true,
        printify_order_id: printify_order_id,
        details: printify_order_details
      }
    rescue => e
      Rails.logger.error "Error processing successful Printify order: #{e.message}"
      handle_order_error(order, e)
    end
  end

  def handle_failed_order(order, response)
    error_message = parse_error_message(response)

    order.update(
      order_status: 'failed',
      error_message: error_message
    )

    {
      success: false,
      error: error_message,
      status_code: response.code,
      details: response.body
    }
  end

  def handle_order_error(order, error)
    error_message = if error.is_a?(PrintifyOrderError)
      error.message
    else
      error.message
    end

    Rails.logger.error "Printify Order Error: #{error_message}"
    Rails.logger.error error.backtrace.join("\n") if error.respond_to?(:backtrace)

    order.update(
      order_status: 'failed',
      error_message: error_message
    )

    {
      success: false,
      error: error_message
    }
  end

  def parse_error_message(response)
    JSON.parse(response.body)['error']
  rescue JSON::ParserError
    response.body
  end

  # Custom error class for Printify-specific errors
  class PrintifyOrderError < StandardError
    attr_reader :status_code, :response_body

    def initialize(message:, status_code: nil, response_body: nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end
end
