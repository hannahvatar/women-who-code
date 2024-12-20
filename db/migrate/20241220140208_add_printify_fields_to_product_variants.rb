class AddPrintifyFieldsToProductVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :product_variants, :printify_variant_id, :string
    add_column :product_variants, :sku, :string
  end
end
