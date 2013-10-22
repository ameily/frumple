class CreateStockHistories < ActiveRecord::Migration
  def change
    create_table :stock_histories do |t|
      t.integer :stock_id
      t.integer :market_id
      t.integer :parent_id
      t.integer :volume
      t.float :price
      t.integer :dv
      t.float :dp
      t.datetime :posted
      t.string :trigger
    end
  end
end
