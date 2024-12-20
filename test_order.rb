require 'net/http'
require 'uri'
require 'json'

def create_test_order
  # Define your shop ID and API key
  shop_id = "15172090" # Replace with your actual Shop ID
  api_key = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIzN2Q0YmQzMDM1ZmUxMWU5YTgwM2FiN2VlYjNjY2M5NyIsImp0aSI6IjMxZjY2NTYwMzk2ZTMyYzEyNGVjNzBkMTg3NTFkODRjMzZjNzA1M2Y5NWY4YTg3OTk4ZmVlMjRjZTc3OGQwYmYwZWY4MDFiZGE1MzBmOWQ3IiwiaWF0IjoxNzM0NzAyNTkxLjQ0NTY4OSwibmJmIjoxNzM0NzAyNTkxLjQ0NTY5MSwiZXhwIjoxNzY2MjM4NTkxLjQzNzQ5OSwic3ViIjoiMTc2NTExNDEiLCJzY29wZXMiOlsic2hvcHMubWFuYWdlIiwic2hvcHMucmVhZCIsImNhdGFsb2cucmVhZCIsIm9yZGVycy5yZWFkIiwib3JkZXJzLndyaXRlIiwicHJvZHVjdHMucmVhZCIsInByb2R1Y3RzLndyaXRlIiwid2ViaG9va3MucmVhZCIsIndlYmhvb2tzLndyaXRlIiwidXBsb2Fkcy5yZWFkIiwidXBsb2Fkcy53cml0ZSIsInByaW50X3Byb3ZpZGVycy5yZWFkIiwidXNlci5pbmZvIl19.AtZkQ02vwFV3A_VLCNoOu7APFQxqE_SmFgpcJUmF93j6cLF6k-psHP6yYx4O95V4GuapMIfU4xvDcsYKR1E" # Replace with your actual API Key

  # Set the API endpoint
  uri = URI("https://api.printify.com/v1/shops/#{shop_id}/orders.json")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  # Set the request headers
  request = Net::HTTP::Post.new(uri.path, {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  })

  # Define the request body
  request.body = {
    external_id: "test_order_001",
    label: "Test Order",
    line_items: [
      { product_id: "12345", variant_id: 67890, quantity: 1 }
    ],
    shipping_method: 1,
    address_to: {
      first_name: "Jane",
      last_name: "Doe",
      email: "jane.doe@example.com",
      phone: "1234567890",
      country: "US",
      region: "CA",
      address1: "123 Test Street",
      city: "Test City",
      zip: "12345"
    }
  }.to_json

  # Log debugging information
  puts "Requesting URL: #{uri}"
  puts "Request Headers: #{request.each_header.to_h}"
  puts "Request Body: #{request.body}"

  # Make the request
  response = http.request(request)

  # Output the response
  puts "Response Code: #{response.code}"
  puts "Response Body: #{response.body}"
end

create_test_order
