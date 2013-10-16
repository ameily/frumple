class CreateStocks < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.integer :user_id
      t.integer :volume
      t.float :price
      t.datetime :last_update
    end
  end
end
