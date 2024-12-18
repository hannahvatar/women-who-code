# app/models/order.rb
class Order < ApplicationRecord
  has_many :order_items
  has_many :product_variants, through: :order_items

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :street_address, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
  validates :phone_number, presence: true
  validates :order_status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_status, presence: true
  validates :shipping_method, presence: true

  def full_address
    [
      street_address,
      apartment,
      city,
      postal_code,
      country
    ].compact.join(", ")
  end
end
