namespace :frumple do
  namespace :import do
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
  end
end