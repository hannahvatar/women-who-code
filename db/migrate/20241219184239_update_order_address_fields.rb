# db/migrate/YYYYMMDDHHMMSS_update_order_address_fields.rb
class UpdateOrderAddressFields < ActiveRecord::Migration[7.1]
  def change
    # First, add new columns
    add_column :orders, :street_address, :string
    add_column :orders, :apartment, :string
    add_column :orders, :city, :string
    add_column :orders, :postal_code, :string
    add_column :orders, :country, :string

    # If you want to copy existing data
    reversible do |dir|
      dir.up do
        # Copy existing shipping_address data if needed
        execute <<-SQL
          UPDATE orders
          SET street_address = shipping_address
          WHERE shipping_address IS NOT NULL;
        SQL
      end
    end

    # Remove old column
    remove_column :orders, :shipping_address
  end
end
