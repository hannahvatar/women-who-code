class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :color
  belongs_to :size
  has_many :order_items
  has_many :orders, through: :order_items

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Validate uniqueness of product/color/size combination
  validates :product_id, uniqueness: { scope: [:color_id, :size_id],
    message: "already has a variant with this color and size" }
end
