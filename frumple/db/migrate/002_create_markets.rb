class CreateMarkets < ActiveRecord::Migration
  def change
    create_table :markets do |t|
      t.integer :project_id
      t.integer :volume
      t.float :price
      t.datetime :last_update
    end
    
    change_table :markets do |t|
        t.remove :fuck
    end
  end
end
