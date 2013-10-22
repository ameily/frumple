namespace :frumple do
  namespace :import do
    desc "Import Repositories"
    task :repos => :environment do
        puts "Importing Repos..."
        objs = [ ]
        repos = { }
        Repository.find_each do |repo|
            repos[repo.id] = repo.project.market
        end
        
        puts "==> Importing Changesets..."
        Changeset.find_each do |cs|
            dv = 1
            dp = 0.01
            trigger = "repo.commit.#{cs.revision}"
            market = repos[cs.repository_id]
            
            dp += 0.005 * cs.issues.length
            
            stock_history = nil
            if cs.user_id
                stock = cs.user.stock
                stock_history = StockHistory.new(
                    :trigger => trigger,
                    :market => market,
                    :dv => dv,
                    :dp => dp,
                    :stock => stock,
                    :posted => cs.committed_on
                )
                objs << stock_history
            end
            
            objs << MarketHistory.create(
                :trigger => trigger,
                :stock_history => stock_history,
                :market => market,
                :dv => dv,
                :dp => dp,
                :posted => cs.committed_on
            )
        end
        
        puts "==> Saving history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
            end
        end
    end
  end
end
