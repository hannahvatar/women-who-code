class AddErrorMessageToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :error_message, :text
  end
end
