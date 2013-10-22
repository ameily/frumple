module Frumple
  module Econ
    class BaseEconomy
        attr_accessor :id
        attr_accessor :name
        attr_accessor :author
        attr_accessor :email
        attr_accessor :version
        attr_accessor :description
        
        def on_event(event)
            case event
            when Events::WikiCreateEvent
                self.on_wiki_event(event)
            else
                raise NotImplementedError
            end
        end
        
        
        def on_wiki_event(event)
            raise NotImplementedError
        end
        
        def on_repo_event(event)
            raise NotImplementedError
        end
        
        def on_attachment_event(event)
            raise NotImplementedError
        end
        
        def on_issue_event(event)
            raise NotImplementedError
        end
    end
  end
end
