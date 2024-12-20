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

  def sync_stock_from_printify
    return unless printify_variant_id.present?

    service = PrintifyService.new
    response = service.get_product(product.printify_id)

    if response.success?
      product_data = JSON.parse(response.body)
      variant_data = product_data["variants"].find { |v| v["id"] == printify_variant_id }

      if variant_data
        update!(stock: variant_data["quantity"])
      end
    end
  end
end
