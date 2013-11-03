module Frumple
    module Hooks
        class AttachmentObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :attachment
            
            def after_create(attachment)
                event = Events::AttachmentUploadEvent(attachment)                
            end
            
            def after_destroy(attachment)
                event = Events::AttachmentDeleteEvent(attachment)
            end
        end
    end
end
