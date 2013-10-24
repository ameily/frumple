namespace :frumple do
  namespace :import do
    desc "Create Markets from Projects"
    task :projects => :environment do
        econ = Frumple::Econ::FairEconomy.new
        Market.delete_all
        MarketHistory.delete_all
        
        events = []
        puts "Importing Projects"
        puts "    Creating events..."
        Project.find_each do |project|
            events.push(
                Frumple::Econ::Events::ProjectCreateEvent.new(project)
            )
        end
        
        puts "    Saving #{events.length} events..."
        Project.transaction do
            events.each do |e|
                econ.dispatch(e)
            end
        end
        
        puts "Done"
    end
  end
end