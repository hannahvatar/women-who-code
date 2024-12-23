# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_12_23_123556) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "colors", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "from", null: false
    t.string "to", null: false
    t.decimal "rate", precision: 10, scale: 6, null: false
    t.datetime "last_updated"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from", "to"], name: "index_exchange_rates_on_from_and_to", unique: true
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_variant_id", null: false
    t.integer "quantity", null: false
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_variant_id"], name: "index_order_items_on_product_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "email", null: false
    t.string "phone_number", null: false
    t.string "order_status", default: "pending", null: false
    t.decimal "total_amount", precision: 10, scale: 2
    t.string "payment_status", default: "pending", null: false
    t.string "shipping_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "street_address"
    t.string "apartment"
    t.string "city"
    t.string "postal_code"
    t.string "country"
    t.string "printify_order_id"
    t.string "first_name"
    t.string "last_name"
    t.string "state"
    t.text "error_message"
    t.string "checkout_session_id"
    t.string "payment_intent_id"
  end

  create_table "printify_products", force: :cascade do |t|
    t.string "printify_id"
    t.bigint "printify_shop_id"
    t.string "title"
    t.text "description"
    t.decimal "price", precision: 10, scale: 2
    t.boolean "is_locked"
    t.json "variants"
    t.json "print_areas"
    t.json "print_details"
    t.string "blueprint_id"
    t.integer "print_provider_id"
    t.json "images"
    t.string "tags", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blueprint_id"], name: "index_printify_products_on_blueprint_id"
    t.index ["printify_id"], name: "index_printify_products_on_printify_id", unique: true
    t.index ["printify_shop_id"], name: "index_printify_products_on_printify_shop_id"
  end

  create_table "printify_shops", force: :cascade do |t|
    t.string "printify_shop_id"
    t.string "title"
    t.string "sales_channel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["printify_shop_id"], name: "index_printify_shops_on_printify_shop_id", unique: true
  end

  create_table "product_variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "color_id", null: false
    t.bigint "size_id", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.integer "stock", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.string "printify_variant_id"
    t.string "sku"
    t.index ["color_id"], name: "index_product_variants_on_color_id"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["size_id"], name: "index_product_variants_on_size_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.decimal "base_price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "printify_id"
    t.json "printify_images"
  end

  create_table "sizes", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants"
  add_foreign_key "printify_products", "printify_shops"
  add_foreign_key "product_variants", "colors"
  add_foreign_key "product_variants", "products"
  add_foreign_key "product_variants", "sizes"
end
