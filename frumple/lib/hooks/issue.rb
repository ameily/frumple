module Frumple
    module Hooks
        class IssueObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :issue
            
            def after_create(issue)
                event = Events::IssueCreateEvent.new(issue)
                event.fire()
            end

            def after_destroy(issue)
                event = Events::IssueDeleteEvent.new(issue)
                event.fire()
            end
        end
    end
end
