class Product < ApplicationRecord
  has_many :product_variants
  has_many :colors, through: :product_variants
  has_many :sizes, through: :product_variants

  validates :name, presence: true
  validates :description, presence: true
  validates :base_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
