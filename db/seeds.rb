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

# Create product variants with images
puts "Creating product variants..."
# Blue variants
ProductVariant.create!(
  product: product,
  color: blue,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/blue_tshirt_front_odinvj.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: medium,
  price: 29.99,
  stock: 15,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/blue_tshirt_front_odinvj.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: large,
  price: 29.99,
  stock: 20,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/blue_tshirt_front_odinvj.jpg"
)

# Red variants
ProductVariant.create!(
  product: product,
  color: red,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/red_tshirt_front_kpxz0n.jpg"
)

ProductVariant.create!(
  product: product,
  color: red,
  size: medium,
  price: 29.99,
  stock: 15,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/red_tshirt_front_kpxz0n.jpg"
)

ProductVariant.create!(
  product: product,
  color: red,
  size: large,
  price: 29.99,
  stock: 20,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/red_tshirt_front_kpxz0n.jpg"
)

# Black variants
ProductVariant.create!(
  product: product,
  color: black,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/black_tshirt_front_gvhpgv.jpg"
)

ProductVariant.create!(
  product: product,
  color: black,
  size: medium,
  price: 29.99,
  stock: 15,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/black_tshirt_front_gvhpgv.jpg"
)

ProductVariant.create!(
  product: product,
  color: black,
  size: large,
  price: 29.99,
  stock: 20,
  image_url: "https://res.cloudinary.com/dp5zxwvrx/image/upload/v1701910901/black_tshirt_front_gvhpgv.jpg"
)

puts "Finished!"
