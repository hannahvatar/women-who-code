class CreateOrders < ActiveRecord::Migration[7.1]  # your Rails version might be different
  def change
    create_table :orders do |t|
      t.string :email
      t.text :shipping_address
      t.string :phone_number
      t.string :order_status
      t.decimal :total_amount
      t.string :payment_status
      t.string :shipping_method

      t.timestamps  # This automatically adds created_at and updated_at
    end
  end
end
