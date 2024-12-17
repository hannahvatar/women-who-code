# Clear existing data
puts "Cleaning database..."
# Must destroy in correct order due to foreign key constraints
OrderItem.destroy_all
Order.destroy_all
ProductVariant.destroy_all
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
purple = Color.create!(name: "Purple")
coral = Color.create!(name: "Coral")
crimson = Color.create!(name: "Crimson")

# Create sizes
puts "Creating sizes..."
small = Size.create!(name: "S")
medium = Size.create!(name: "M")
large = Size.create!(name: "L")
xlarge = Size.create!(name: "XL")
xxlarge = Size.create!(name: "2XL")
xxxlarge = Size.create!(name: "3XL")

# Create product variants with images
puts "Creating product variants..."
# Blue variants
ProductVariant.create!(
  product: product,
  color: blue,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: medium,
  price: 29.99,
  stock: 15,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: large,
  price: 29.99,
  stock: 20,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: xlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: xxlarge,
  price: 29.99,
  stock: 15,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
)

ProductVariant.create!(
  product: product,
  color: blue,
  size: xxxlarge,
  price: 29.99,
  stock: 20,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_blue_anl1zo.jpg"
)

# Purple variants
ProductVariant.create!(
  product: product,
  color: purple,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg"
)

ProductVariant.create!(
  product: product,
  color: purple,
  size: medium,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg"
)

ProductVariant.create!(
  product: product,
  color: purple,
  size: large,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg"
)

ProductVariant.create!(
  product: product,
  color: purple,
  size: xlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg"
)

ProductVariant.create!(
  product: product,
  color: purple,
  size: xxlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg"
)

ProductVariant.create!(
  product: product,
  color: purple,
  size: xxxlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458160/sweater_purple_zixn0s.jpg"
)

# Coral variants
ProductVariant.create!(
  product: product,
  color: coral,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg"
)

ProductVariant.create!(
  product: product,
  color: coral,
  size: medium,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg"
)

ProductVariant.create!(
  product: product,
  color: coral,
  size: large,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg"
)

ProductVariant.create!(
  product: product,
  color: coral,
  size: xlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg"
)

ProductVariant.create!(
  product: product,
  color: coral,
  size: xxlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg"
)

ProductVariant.create!(
  product: product,
  color: coral,
  size: xxxlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_coral_dsso00.jpg"
)

# Crimson variants
ProductVariant.create!(
  product: product,
  color: crimson,
  size: small,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg"
)

ProductVariant.create!(
  product: product,
  color: crimson,
  size: medium,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg"
)

ProductVariant.create!(
  product: product,
  color: crimson,
  size: large,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg"
)

ProductVariant.create!(
  product: product,
  color: crimson,
  size: xlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg"
)

ProductVariant.create!(
  product: product,
  color: crimson,
  size: xxlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg"
)

ProductVariant.create!(
  product: product,
  color: crimson,
  size: xxxlarge,
  price: 29.99,
  stock: 10,
  image_url: "https://res.cloudinary.com/diwuyv3c8/image/upload/v1734458159/sweater_crimson_kplpcr.jpg"
)

puts "Finished!"
