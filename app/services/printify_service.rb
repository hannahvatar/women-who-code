class PrintifyService
  include HTTParty
  base_uri 'https://api.printify.com/v1'

  SHOP_ID = '15172090'

  def initialize
    @headers = {
      'Authorization': "Bearer #{ENV['PRINTIFY_API_KEY']}",
      'Content-Type': 'application/json'
    }
  end

  def test_connection
    self.class.get('/shops.json', headers: @headers)
  end

  def get_products
    self.class.get("/shops/#{SHOP_ID}/products.json", headers: @headers)
  end

  def get_product(product_id)
    self.class.get(
      "/shops/#{SHOP_ID}/products/#{product_id}.json",
      headers: @headers
    )
  end

  def create_order(order_data)
    self.class.post(
      "/shops/#{SHOP_ID}/orders.json",
      headers: @headers,
      body: order_data.to_json
    )
  end

  def prepare_printify_order(order)
    # Ensure we have at least one order item
    raise "Order must have at least one item" if order.order_items.empty?

    # Get the first order item (assuming single item for now)
    order_item = order.order_items.first
    product_variant = order_item.product_variant
    product = product_variant.product

    # Get the product details to find the print provider
    product_response = get_product(product.printify_id)
    product_data = JSON.parse(product_response.body)

    # Determine print provider and blueprint ID
    print_provider_id = product_data['print_providers'].first['id']
    blueprint_id = product_data['blueprint_id']

    # Prepare print areas with Printify's image details
    print_areas = product_data['print_areas'].map do |area|
      if area['variant_ids'].include?(product_variant.printify_variant_id.to_s)
        placeholders = area['placeholders'].map do |placeholder|
          # Use the first image from Printify's configuration
          placeholder_images = placeholder['images'].map do |image|
            {
              id: image['id'],
              src: image['src'],
              x: 0.5,        # Default centered positioning
              y: 0.5,
              scale: 1.0,
              angle: 0
            }
          end

          {
            position: placeholder['position'],
            images: placeholder_images
          }
        end

        {
          variant_ids: [product_variant.printify_variant_id],
          placeholders: placeholders
        }
      end
    end.compact

    {
      external_id: order.id.to_s,
      label: order.full_name,
      line_items: [
        {
          print_provider_id: print_provider_id,
          blueprint_id: blueprint_id,
          variant_id: product_variant.printify_variant_id,
          quantity: order_item.quantity,
          print_areas: print_areas
        }
      ],
      shipping_method: 2,
      recipients: [
        {
          name: order.full_name,
          email: order.email,
          phone: order.phone_number,
          address1: order.street_address,
          address2: order.apartment || '',
          city: order.city,
          state: order.state || '',
          postal_code: order.postal_code,
          country: order.country,
          company: ''
        }
      ]
    }
  end

  def send_order_to_printify(order, test_mode: true)
    # Prepare order data
    order_data = prepare_printify_order(order)

    # Add test mode flag if needed
    order_data[:test_mode] = test_mode

    # Send order to Printify
    response = create_order(order_data)

    # Update order with Printify response
    if response.success?
      begin
        printify_order_id = JSON.parse(response.body)['id']
        order.update(printify_order_id: printify_order_id, order_status: 'processing')
        { success: true, printify_order_id: printify_order_id }
      rescue JSON::ParserError => e
        {
          success: false,
          error: "Failed to parse Printify response: #{e.message}",
          raw_response: response.body
        }
      end
    else
      # Log the full response for debugging
      {
        success: false,
        error: response.body,
        details: "Order submission failed"
      }
    end
  end
end
