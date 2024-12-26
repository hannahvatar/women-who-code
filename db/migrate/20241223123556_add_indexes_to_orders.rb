class AddIndexesToOrders < ActiveRecord::Migration[7.1]
  def change
    add_index :orders, :checkout_session_id unless index_exists?(:orders, :checkout_session_id)
    add_index :orders, :payment_intent_id unless index_exists?(:orders, :payment_intent_id)
  end
end
