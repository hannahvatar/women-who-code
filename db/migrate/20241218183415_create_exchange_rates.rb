class CreateExchangeRates < ActiveRecord::Migration[7.1]
  def change
    create_table :exchange_rates do |t|
      t.string :from, null: false
      t.string :to, null: false
      t.decimal :rate, precision: 10, scale: 6, null: false
      t.datetime :last_updated

      t.timestamps
    end

    add_index :exchange_rates, [:from, :to], unique: true
  end
end
