namespace :frumple do
  namespace :import do
    desc "Import Wiki Pages"
    task :wiki => :environment do
        econ = Frumple::Econ::FairEconomy.new()
        events = []
        
        puts "Importing Wiki Content"
        print "    Creating wiki events... "
        $stdout.flush
        Wiki.find_each do |wiki|
            events << Frumple::Econ::Events::WikiCreateEvent.new(wiki)
        end
        puts "Done!"
        
        print "    Creating page events... "
        $stdout.flush
        WikiPage.find_each do |page|
            events << Frumple::Econ::Events::WikiPageCreateEvent.new(page)
            page.content.versions.each do |v|
                events << Frumple::Econ::Events::WikiPageEditEvent.new(v)
            end
        end
        puts "Done!"
        
        print "    Saving #{events.length} events.. "
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
