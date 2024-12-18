class Size < ApplicationRecord
  has_many :product_variants

  validates :name, presence: true, uniqueness: true
  validates :order, numericality: { greater_than_or_equal_to: 1 }, allow_nil: true
end
