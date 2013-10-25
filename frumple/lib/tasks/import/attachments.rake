namespace :frumple do
  namespace :import do
    desc "Import Attachments"
    task :attachments => :environment do
        econ = Frumple::Econ::FairEconomy.new
        events = []
        puts "Importing Attachments"
        print "    Creating events... "
        $stdout.flush()
        Attachment.find_each do |attach|
            events.push(
                Frumple::Econ::Events::AttachmentUploadEvent.new(attach)
            )
        end
        
        puts "Done!"
        print "    Saving #{events.length} events... "
        $stdout.flush()
        
        Attachment.transaction do
            events.each do |e|
                econ.dispatch(e)
            end
        end
        
        puts "Done!"
        puts "Done"
    end
  end
end
