class CreateStockHistories < ActiveRecord::Migration
  def change
    create_table :stock_histories do |t|
      t.integer :stock_id
      t.integer :volume
      t.float :price
      t.integer :dv
      t.float :dp
      t.datetime :posted
      t.string :action
    end
  end
end
