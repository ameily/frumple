namespace :frumple do
  namespace :import do
    desc "Initialize frumple from existing data"
    task :all => [:projects, :users, :repos]
    
    desc "Create Markets from Projects"
    task :projects => :environment do
        Market.delete_all
        MarketHistory.delete_all
        
        puts "Importing Projects..."
        Project.find_each do |project|
            Market.create(
                :project => project,
                :volume => 0,
                :price => 0.20,
                :last_update => project.created_on
            )
        end
    end
    
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
    
    desc "Import Repositories"
    task :repos => :environment do
        puts "Importing Repositories..."
        repos = { }
        Repository.find_each do |repo|
            repos[repo.id] = repo.project.market
        end
        
        Changeset.find_each do |cs|
            dv = 5
            dp = 0.20
            action = "repo.commit.#{cs.revision}"
            market = repos[cs.repository_id]
            
            stock_id = nil
            if cs.user_id
                stock = cs.user.stock
                stock_id = stock.id
                StockHistory.create(
                    :action => action,
                    :dv => dv,
                    :dp => dp,
                    :stock => stock,
                    :posted => cs.committed_on
                )
            end
            
            MarketHistory.create(
                :action => action,
                :stock_id => stock_id,
                :market => market,
                :dv => dv,
                :dp => dp,
                :posted => cs.committed_on
            )
        end
    end
  end
end
