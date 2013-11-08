module Frumple
    module Hooks
        class JournalDetailObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :journal_detail
            
            def after_create(detail)
                event = Events::JournalDetailCreateEvent.Spec(detail)
                if event
                    event.fire()
                end
            end
        end
    end
end
