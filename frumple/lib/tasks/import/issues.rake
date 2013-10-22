namespace :frumple do
  namespace :import do
    desc "Import Issues"
    task :issues => :environment do
        objs = [ ]
        puts "Importing Issues..."
        Issue.find_each do |issue|
            market = issue.project.market
            stock = issue.author.stock
            trigger = "issue.#{issue.id}.create"
            dvs = {
                "Feature" => 5,
                "Support" => 3,
                "Bug" => 10
            }
            
            dps = {
                "Feature" => 0.07,
                "Bug" => 0.10,
                "Support" => 0.5
            }
            
            dv = dvs[issue.tracker.name]
            dp = dps[issue.tracker.name]
            
            objs << MarketHistory.new(
                :market => market,
                :stock_id => stock_id,
                :dv => dv,
                :dp => dp,
                :trigger => trigger,
                :posted => issue.created_on
            )
            
            objs << StockHistory.new(
                :stock => stock,
                :dv => dv,
                :dp => dp,
                :trigger => trigger,
                :posted => issue.created_on
            )
            
            # TODO journals (straight content)
            # TODO journal details (meta: assignment, and whatnot)
        end
        
        puts "==> Saving stock/market history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
            end
        end
    end
  end
end