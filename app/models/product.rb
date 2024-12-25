class Product < ApplicationRecord
  has_many :product_variants
  has_many :colors, through: :product_variants
  has_many :sizes, through: :product_variants

  validates :name, presence: true
  validates :description, presence: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :printify_id, uniqueness: true, allow_nil: true

  def base_price
    WomenWhoCode::Config::RETAIL_PRICE
  end

  def sync_from_printify(printify_data)
    self.transaction do
      # Update product details
      self.update!(
        printify_id: printify_data["id"],
        name: printify_data["title"],
        description: printify_data["description"],
        base_price: printify_data["variants"].first["price"].to_f / 100,
        printify_images: printify_data["images"]
      )

      # Sync variants
      printify_data["variants"].each do |variant_data|
        color_name = variant_data["title"].split(" / ").first
        size_name = variant_data["title"].split(" / ").last

        color = Color.find_or_create_by!(name: color_name)
        size = Size.find_or_create_by!(name: size_name)

        variant = product_variants.find_or_initialize_by(
          color: color,
          size: size
        )

        variant.update!(
          printify_variant_id: variant_data["id"],
          sku: variant_data["sku"],
          price: variant_data["price"].to_f / 100,
          stock: variant_data["quantity"]
        )
      end
    end
  end

  def self.sync_all_from_printify
    service = PrintifyService.new
    response = service.get_products

    if response.success?
      products_data = JSON.parse(response.body)["data"]

      products_data.each do |product_data|
        product = Product.find_or_initialize_by(printify_id: product_data["id"])
        product.sync_from_printify(product_data)
      end
    else
      raise "Failed to sync products from Printify: #{response.body}"
    end
  end
end
