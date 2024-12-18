# config/initializers/geocoder.rb
if Rails.env.development?
  Geocoder.configure(
    ip_lookup: :test,
    # Add test IP addresses for different countries
    ip_lookup_test: {
      "123.45.67.89" => {
        ip: "123.45.67.89",
        country_code: "GB",
        country_name: "United Kingdom"
      },
      # Add more test IPs as needed
    }
  )
end
