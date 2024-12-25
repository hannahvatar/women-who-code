class Order < ApplicationRecord
  has_many :order_items
  has_many :product_variants, through: :order_items

  attribute :error_message, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :street_address, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true, inclusion: {
    in: %w(CA US FR GB DE IT ES NL BE CH SE NO DK FI IE AT PT GR),
    message: "is not a supported country"
  }
  validates :phone_number, presence: true
  validates :order_status, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_status, presence: true
  validates :shipping_method, presence: true
  validates :state, presence: true, unless: -> { country.in?(['AQ', 'NL', 'SJ', 'BR']) }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :checkout_session_id, uniqueness: true, allow_nil: true

  def total_amount
    order_items.sum { |item| item.unit_price * item.quantity }
  end

  def full_address
    [
      street_address,
      apartment,
      city,
      postal_code,
      country
    ].compact.join(", ")
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
