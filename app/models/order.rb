class Order < ApplicationRecord
  has_many :order_items
  has_many :product_variants, through: :order_items

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :shipping_address, presence: true
  validates :phone_number, presence: true
  validates :order_status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_status, presence: true
  validates :shipping_method, presence: true
end