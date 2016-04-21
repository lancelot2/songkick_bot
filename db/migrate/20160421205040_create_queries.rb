class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.string :style
      t.string :gender
      t.string :brand

      t.timestamps null: false
    end
  end
end
