class AddPrintifyFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :printify_id, :string
    add_column :products, :printify_images, :json
  end
end
