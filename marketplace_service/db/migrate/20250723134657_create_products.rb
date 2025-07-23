class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string :name
      t.decimal :price
      t.integer :sold_qty, default: 0

      t.timestamps
    end
  end
end
