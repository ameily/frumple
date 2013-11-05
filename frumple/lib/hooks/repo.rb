module Frumple
    module Hooks
        class ChangesetObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :changeset
            
            def after_create(changeset)
                event = Events::RepoCommitEvent.new(changeset)
                event.fire()
            end
        end
    end
end
