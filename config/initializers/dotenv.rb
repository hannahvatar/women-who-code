# config/initializers/dotenv.rb
if Rails.env.development? || Rails.env.test?
  Dotenv::Railtie.load
end
