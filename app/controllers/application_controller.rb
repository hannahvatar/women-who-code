# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_currency

  private

  def set_currency
    @current_currency = currency_by_location || "USD"
  end

  def currency_by_location
    # In development, use a default country for testing
    if Rails.env.development?
      return "CAD" # or any default currency you want to test with
    end

    country = request.location&.country_code

    case country
    when "GB" then "GBP"
    when "CA" then "CAD"
    when "AU" then "AUD"
    when "JP" then "JPY"
    # European Union countries
    when "FR", "DE", "IT", "ES", "NL", "BE", "AT", "IE", "FI", "PT", "GR" then "EUR"
    else "USD" # Default to USD if country not matched
    end
  end

  def format_price(price)
    case @current_currency
    when "USD" then "$#{price}"
    when "EUR" then "€#{price}"
    when "GBP" then "£#{price}"
    when "CAD" then "C$#{price}"
    when "AUD" then "A$#{price}"
    when "JPY" then "¥#{price}"

    end
  end
  helper_method :format_price
end
