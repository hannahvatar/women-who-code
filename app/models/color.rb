class Color < ApplicationRecord
  has_many :product_variants
  validates :name, presence: true, uniqueness: true
end
