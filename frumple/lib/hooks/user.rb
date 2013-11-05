module Frumple
    module Hooks
        class UserObserver < ActiveRecord::Observer
            Events = Frumple::Econ::Events
            observe :user
            
            def after_create(user)
                event = Events::UserRegisterEvent.new(user)
                event.fire()
            end
            
            #def after_destroy(user)
            #    event = Events::AttachmentDeleteEvent.new(user)
            #    event.fire()
            #end
        end
    end
end
