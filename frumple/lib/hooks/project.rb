module Frumple
    module Hooks
        class ProjectObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :project
            
            def after_create(project)
                event = Events::ProjectCreateEvent.new(project)
                event.fire()
            end
            
            #def after_destroy(attachment)
            #    event = Events::AttachmentDeleteEvent.new(attachment)
            #    event.fire()
            #end
        end
    end
end
