class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :color
  belongs_to :size
  has_many :order_items
  has_many :orders, through: :order_items

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: [:color_id, :size_id],
    message: "already has a variant with this color and size" }
  validates :printify_variant_id, uniqueness: true, allow_nil: true

  def price
    product.base_price
  end

  # app/models/product_variant.rb
  def printify_color_name
    color_mapping = {
      'Flo Blue' => 'Blue',
      'Watermelon' => 'Coral',
      'Crimson' => 'Crimson',
      'Violet' => 'Purple'
    }
    color_mapping[color.name] || color.name
  end

  def sync_stock_from_printify
    return unless printify_variant_id.present?

    service = PrintifyService.new
    response = service.get_product(product.printify_id)

    if response.success?
      product_data = JSON.parse(response.body)
      puts "Response Body: #{JSON.pretty_generate(product_data)}" # Log the entire response for inspection

      variants = product_data["variants"]
      puts "Variants: #{variants}"  # Log the variants array to see all the available variants

      variant_data = variants.find { |v| v["id"].to_s == printify_variant_id.to_s }

      if variant_data
        puts "Found variant data: #{variant_data}"
        update!(stock: variant_data["quantity"])
      else
        puts "Variant not found in the response."
      end
    else
      puts "Error with Printify response: #{response.body}"
    end
  end
end
