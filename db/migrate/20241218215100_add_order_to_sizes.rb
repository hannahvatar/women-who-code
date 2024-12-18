class AddOrderToSizes < ActiveRecord::Migration[7.1]
  def change
    add_column :sizes, :order, :integer
  end
end
