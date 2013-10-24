namespace :frumple do
  namespace :import do
    desc "Create Stocks from Users"
    task :users => :environment do
        econ = Frumple::Econ::FairEconomy.new
        Stock.delete_all
        StockHistory.delete_all
        
        events = []
        puts "Importing Users"
        puts "    Creating events..."
        User.find_each do |user|
            events.push(
                Frumple::Econ::Events::UserRegisterEvent.new(user)
            )
        end
        
        puts "    Saving #{events.length} events..."
        User.transaction do
            events.each do |e|
                econ.dispatch(e)
            end
        end
        
        puts "Done"
    end
  end
end
