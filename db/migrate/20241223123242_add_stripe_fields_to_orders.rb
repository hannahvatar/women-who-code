class AddStripeFieldsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :checkout_session_id, :string
    add_column :orders, :payment_intent_id, :string
    add_index :orders, :checkout_session_id
    add_index :orders, :payment_intent_id
  end
end
