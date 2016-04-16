class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :beer_brand
      t.integer :amount
      t.string :size
      t.integer :table
      t.integer :price

      t.timestamps null: false
    end
  end
end
