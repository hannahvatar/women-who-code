# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
puts "Cleaning database..."
Product.destroy_all
Color.destroy_all
Size.destroy_all

# Create a product
puts "Creating product..."
product = Product.create!(
  name: "Classic T-Shirt",
  description: "A comfortable cotton t-shirt",
  base_price: 29.99
)

# Create colors
puts "Creating colors..."
blue = Color.create!(name: "Blue")
red = Color.create!(name: "Red")
black = Color.create!(name: "Black")

# Create sizes
puts "Creating sizes..."
small = Size.create!(name: "S")
medium = Size.create!(name: "M")
large = Size.create!(name: "L")

# Create product variants
puts "Creating product variants..."
ProductVariant.create!(
  product: product,
  color: blue,
  size: small,
  price: 29.99,
  stock: 10
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: medium,
  price: 29.99,
  stock: 15
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: large,
  price: 29.99,
  stock: 20
)

ProductVariant.create!(
  product: product,
  color: red,
  size: small,
  price: 29.99,
  stock: 10
)

ProductVariant.create!(
  product: product,
  color: red,
  size: medium,
  price: 29.99,
  stock: 15
)

ProductVariant.create!(
  product: product,
  color: red,
  size: large,
  price: 29.99,
  stock: 20
)

ProductVariant.create!(
  product: product,
  color: black,
  size: small,
  price: 29.99,
  stock: 10
)

ProductVariant.create!(
  product: product,
  color: black,
  size: medium,
  price: 29.99,
  stock: 15
)

ProductVariant.create!(
  product: product,
  color: black,
  size: large,
  price: 29.99,
  stock: 20
)

puts "Finished!"
