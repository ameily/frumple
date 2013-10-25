namespace :frumple do
  namespace :import do
    desc "Import Repositories"
    task :repos => :environment do
        econ = Frumple::Econ::FairEconomy.new()
        events = []
        puts "Importing Repositories"
        print "    Creating commit events... "
        $stdout.flush
        
        Changeset.find_each do |cs|
            events << Frumple::Econ::Events::RepoCommitEvent.new(cs)
        end
        
        puts "Done!"
        print "    Saving #{events.length} events... "
        $stdout.flush
        
        Project.transaction do
            events.each do |e|
                econ.dispatch(e)
            end
        end
        
        puts "Done!"
        puts "Done"
    end
  end
end
