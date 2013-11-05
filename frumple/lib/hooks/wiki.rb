module Frumple
    module Hooks
        class WikiObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :wiki
            
            def after_create(wiki)
                event = Events::WikiCreateEvent.new(wiki)
                event.fire()
            end
            
            #def after_destroy(attachment)
            #    event = Events::AttachmentDeleteEvent.new(attachment)
            #    event.fire()
            #end
        end
        
        class WikiPageObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :wiki_page
            
            def after_create(page)
                event = Events::WikiPageCreateEvent.new(page)
                event.fire()
            end
        end
        
        class WikiContentObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :wiki_content
            
            def after_create(content)
                event = Events::WikiPageEditEvent.new(content)
                event.fire()
            end
        end
    end
end



