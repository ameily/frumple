namespace :frumple do
  namespace :import do
    desc "Create Stocks from Users"
    task :users => :environment do
        Stock.delete_all
        StockHistory.delete_all
        
        puts "Importing Users..."
        User.find_each do |user|
            Stock.create(
                :user => user,
                :volume => 0,
                :price => 0.20,
                :last_update => user.created_on
            )
        end
    end
  end
end
