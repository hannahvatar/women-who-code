require 'httparty'

PROVIDER_ID = 99
PROVIDER_TITLE = "Printify Choice"
PROVIDER_LOCATION = {
  address1: "16085 NW 52ND Avenue",
  city: "Miami",
  country: "US",
  region: "FL",
  zip: "33014"
}

  VARIANTS = [
    {
      color: "Flo Blue",
      sizes: [
        {id: 96869, title: "Flo Blue", options: {size: "S", color: "Flo Blue"}},
        {id: 96870, title: "Flo Blue", options: {size: "M", color: "Flo Blue"}},
        {id: 96871, title: "Flo Blue", options: {size: "L", color: "Flo Blue"}},
        {id: 96872, title: "Flo Blue", options: {size: "XL", color: "Flo Blue"}},
        {id: 96873, title: "Flo Blue", options: {size: "2XL", color: "Flo Blue"}},
        {id: 102366, title: "Flo Blue", options: {size: "3XL", color: "Flo Blue"}}
      ]
    },
    {
      color: "Violet",
      sizes: [
        {id: 96909, title: "Violet", options: {size: "S", color: "Violet"}},
        {id: 96910, title: "Violet", options: {size: "M", color: "Violet"}},
        {id: 96911, title: "Violet", options: {size: "L", color: "Violet"}},
        {id: 96912, title: "Violet", options: {size: "XL", color: "Violet"}},
        {id: 96913, title: "Violet", options: {size: "2XL", color: "Violet"}},
        {id: 102374, title: "Violet", options: {size: "3XL", color: "Violet"}}
      ]
    },
    {
      color: "Watermelon",
      sizes: [
        {id: 96914, title: "Watermelon", options: {size: "S", color: "Watermelon"}},
        {id: 96915, title: "Watermelon", options: {size: "M", color: "Watermelon"}},
        {id: 96916, title: "Watermelon", options: {size: "L", color: "Watermelon"}},
        {id: 96917, title: "Watermelon", options: {size: "XL", color: "Watermelon"}},
        {id: 96918, title: "Watermelon", options: {size: "2XL", color: "Watermelon"}},
        {id: 102375, title: "Watermelon", options: {size: "3XL", color: "Watermelon"}}
      ]
    },
    {
      color: "Crimson",
      sizes: [
        {id: 96859, title: "Crimson", options: {size: "S", color: "Crimson"}},
        {id: 96860, title: "Crimson", options: {size: "M", color: "Crimson"}},
        {id: 96861, title: "Crimson", options: {size: "L", color: "Crimson"}},
        {id: 96862, title: "Crimson", options: {size: "XL", color: "Crimson"}},
        {id: 96863, title: "Crimson", options: {size: "2XL", color: "Crimson"}},
        {id: 102364, title: "Crimson", options: {size: "3XL", color: "Crimson"}}
      ]
    }
  ]

  PLACEHOLDERS = [
    {
      position: "front",
      images: [
        {
          id: "67618f64170218383882fad6",
          name: "wwc-artwork-v01.svg",
          type: "image/png",
          height: 3073,
          width: 4069,
          x: 0.5,
          y: 0.5,
          scale: 0.9012063391941969,
          angle: 0,
          src: "https://pfy-prod-image-storage.s3.us-east-2.amazonaws.com/17651141/bb6ff1b1-8377-4485-ad9f-0e601666cb15"
        }
      ]
    },
    {
      position: "back",
      images: []
    }
  ]

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
      begin
        headers = {
          'Authorization' => "Bearer #{ENV.fetch('PRINTIFY_API_KEY')}",
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }

        response = self.class.post(
          "/shops/#{SHOP_ID}/orders.json",
          headers: headers,
          body: order_data.to_json,
          timeout: TIMEOUT
        )

        Rails.logger.info "Printify API Response:"
        Rails.logger.info "Status: #{response.code}"
        Rails.logger.info "Headers: #{response.headers}"
        Rails.logger.info "Body: #{response.body}"

        if response.success?
          parsed_response = JSON.parse(response.body)
          {
            success: true,
            response: response,
            body: parsed_response
          }
        else
          error_message = begin
            parsed_response = JSON.parse(response.body)
            parsed_response['message'] || parsed_response['error'] || response.body
          rescue JSON::ParserError
            response.body
          end

          Rails.logger.error "Printify Error Response:"
          Rails.logger.error "Status: #{response.code}"
          Rails.logger.error "Error: #{error_message}"

          {
            success: false,
            error: error_message,
            status: response.code
          }
        end
      rescue => e
        Rails.logger.error "Printify API Error: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        {
          success: false,
          error: e.message,
          status: 500
        }
      end
    end

    def prepare_printify_order(order)
      validate_order(order)

      line_items = order.order_items.includes(:product_variant).map do |item|
        {
          product_id: "67618fb75d0f6a015c058749",
          variant_id: item.product_variant.printify_variant_id,
          quantity: item.quantity
        }
      end

      # Format phone with international code
      formatted_phone = if order.phone_number.start_with?('+')
                         order.phone_number
                       else
                         "+1#{order.phone_number.gsub(/\D/, '')}"
                        end

      # Format postal code
      formatted_postal = order.postal_code.gsub(/[\s-]/, '').upcase

      data = {
        external_id: order.id.to_s,
        line_items: line_items,
        shipping_method: get_shipping_method(order.shipping_method),
        address_to: {  # Changed to address_to
          first_name: order.first_name.strip,
          last_name: order.last_name.strip,
          email: order.email.strip,
          phone: formatted_phone,
          address1: order.street_address.strip,
          address2: order.apartment.presence&.strip || '',
          city: order.city.strip,
          region: order.state.strip,
          zip: formatted_postal,
          country: normalize_country_code(order.country),
          company: ''
        },
        send_shipping_notification: true
      }

      Rails.logger.info "-------- Printify Order Debug --------"
      Rails.logger.info "Address Details:"
      data[:address_to].each do |key, value|
        Rails.logger.info "#{key}: '#{value}'"
      end
      Rails.logger.info "Full order data:"
      Rails.logger.info data.to_json
      Rails.logger.info "-------- End Debug --------"

      data
    end

    def send_order_to_printify(order, test_mode: false, paid: false)
      begin
        order_data = prepare_printify_order(order)
        order_data[:test_mode] = test_mode
        order_data[:is_paid] = paid # Add payment confirmation

        # Log order details
        Rails.logger.info "------------ PRINTIFY ORDER DEBUG ------------"
        Rails.logger.info "Processing order #{order.id}"
        Rails.logger.info "Line items count: #{order.order_items.count}"
        Rails.logger.info "Payment status: #{paid ? 'Paid' : 'Unpaid'}"
        Rails.logger.info "Test mode: #{test_mode}"

        result = create_order(order_data)
        Rails.logger.info "Printify API Response: #{result.inspect}"
        Rails.logger.info "Printify API call completed"
        Rails.logger.info "------------------------------------------"

        if result[:success]
          order.update(
            printify_order_id: result[:response]["id"],
            order_status: paid ? 'processing' : 'pending_payment'
          )
        end

        result
      rescue => e
        Rails.logger.error "Printify Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        { success: false, error: e.message }
      end
     end

    private


    def normalize_country_code(country)
      # If it's already a 2-letter code, return it uppercase
      return country.upcase if country.length == 2

      country_map = {
        'Canada' => 'CA',
        'United States' => 'US',
        'France' => 'FR',
        'United Kingdom' => 'GB',
        'Germany' => 'DE',
        'Italy' => 'IT',
        'Spain' => 'ES',
        'Netherlands' => 'NL',
        'Belgium' => 'BE',
        'Switzerland' => 'CH',
        'Sweden' => 'SE',
        'Norway' => 'NO',
        'Denmark' => 'DK',
        'Finland' => 'FI',
        'Ireland' => 'IE',
        'Austria' => 'AT',
        'Portugal' => 'PT',
        'Greece' => 'GR'
      }

      normalized = country_map[country.strip] || country.strip
      Rails.logger.info "Country normalization: '#{country}' -> '#{normalized}'"
      normalized
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

    def validate_order(order)
      required_fields = {
        'First name' => order.first_name,
        'Last name' => order.last_name,
        'Email' => order.email,
        'Phone number' => order.phone_number,
        'Street address' => order.street_address,
        'City' => order.city,
        'State/Province' => order.state,
        'Postal code' => order.postal_code,
        'Country' => order.country
      }

      missing_fields = required_fields.select { |_, value| value.blank? }
                                    .keys

      if missing_fields.any?
        error_message = "Missing required fields: #{missing_fields.join(', ')}"
        Rails.logger.error error_message
        raise PrintifyOrderError.new(message: error_message)
      end
    end

    def validate_product_variant(product_variant)
      color_name = product_variant.color.name
      size_name = product_variant.size.name

      variant = VARIANTS.find do |v|
        v[:color].downcase == color_name.downcase &&
        v[:sizes].any? { |s| s[:options][:size] == size_name }
      end

      if variant
        size = variant[:sizes].find { |s| s[:options][:size] == size_name }
        size[:id]
      else
        raise "No valid Printify variant found for color: #{color_name}, size: #{size_name}"
      end
    end

    def prepare_line_item(order_item)
      product_variant = order_item.product_variant

      {
        product_id: "67618fb75d0f6a015c058749",
        variant_id: product_variant.printify_variant_id,  # Use the stored printify_variant_id
        quantity: order_item.quantity
      }
    end

    def get_shipping_method(method)
      shipping_method_map = {
        'Standard' => 1,
        'Express' => 2,
        'Economy' => 3 # Add more methods as needed
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
        error.to_s
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
      attr_reader :status_code, :response_body, :request_data

      def initialize(message:, status_code: nil, response_body: nil, request_data: nil)
        super(message)
        @status_code = status_code
        @response_body = response_body
        @request_data = request_data
      end

      def to_s
        "#{message} (Status: #{status_code})\nResponse: #{response_body}\nRequest: #{request_data}"
      end
    end
  end
