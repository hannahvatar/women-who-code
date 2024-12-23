# config/initializers/printify.rb
unless Rails.env.test?
  required_vars = ['PRINTIFY_API_KEY', 'PRINTIFY_SHOP_ID']
  missing_vars = required_vars.select { |var| ENV[var].blank? }

  if missing_vars.any?
    raise "Missing required Printify environment variables: #{missing_vars.join(', ')}"
  end
end
