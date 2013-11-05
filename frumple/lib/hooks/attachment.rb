module Frumple
    module Hooks
        class AttachmentObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :attachment
            
            def after_create(attachment)
                event = Events::AttachmentUploadEvent.new(attachment)
                event.fire()
            end
            
            def after_destroy(attachment)
                event = Events::AttachmentDeleteEvent.new(attachment)
                event.fire()
            end
        end
    end
end
