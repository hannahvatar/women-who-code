class AddImageUrlToProductVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :product_variants, :image_url, :string
  end
end