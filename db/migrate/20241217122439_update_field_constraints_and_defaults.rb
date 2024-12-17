class UpdateFieldConstraintsAndDefaults < ActiveRecord::Migration[7.1]
  def up
    # Update decimal columns with precision
    change_column :products, :base_price, :decimal, precision: 10, scale: 2, null: false
    change_column :product_variants, :price, :decimal, precision: 10, scale: 2, null: false
    change_column :orders, :total_amount, :decimal, precision: 10, scale: 2
    change_column :order_items, :unit_price, :decimal, precision: 10, scale: 2, null: false

    # Add default values
    change_column_default :orders, :order_status, from: nil, to: 'pending'
    change_column_default :orders, :payment_status, from: nil, to: 'pending'
    change_column_default :product_variants, :stock, from: nil, to: 0

    # Add null constraints
    change_column_null :colors, :name, false
    change_column_null :sizes, :name, false
    change_column_null :orders, :email, false
    change_column_null :orders, :shipping_address, false
    change_column_null :orders, :phone_number, false
    change_column_null :orders, :order_status, false
    change_column_null :orders, :payment_status, false
    change_column_null :products, :name, false
    change_column_null :order_items, :quantity, false
    change_column_null :product_variants, :stock, false
  end

  def down
    # Revert decimal columns
    change_column :products, :base_price, :decimal
    change_column :product_variants, :price, :decimal
    change_column :orders, :total_amount, :decimal
    change_column :order_items, :unit_price, :decimal

    # Remove default values
    change_column_default :orders, :order_status, from: 'pending', to: nil
    change_column_default :orders, :payment_status, from: 'pending', to: nil
    change_column_default :product_variants, :stock, from: 0, to: nil

    # Remove null constraints
    change_column_null :colors, :name, true
    change_column_null :sizes, :name, true
    change_column_null :orders, :email, true
    change_column_null :orders, :shipping_address, true
    change_column_null :orders, :phone_number, true
    change_column_null :orders, :order_status, true
    change_column_null :orders, :payment_status, true
    change_column_null :products, :name, true
    change_column_null :order_items, :quantity, true
    change_column_null :product_variants, :stock, true
  end
end
