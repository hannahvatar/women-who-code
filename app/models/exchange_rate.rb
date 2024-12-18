class ExchangeRate < ApplicationRecord
  validates :from, presence: true
  validates :to, presence: true
  validates :rate, presence: true, numericality: { greater_than: 0 }

  def self.convert(amount, from: "USD", to:)
    return amount if from == to

    rate = find_by(from: from, to: to)&.rate || 1.0
    (amount * rate).round(2)
  end
end
