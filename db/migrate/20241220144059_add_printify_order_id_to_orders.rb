class AddPrintifyOrderIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :printify_order_id, :string
  end
end
