
module Frumple
  module Econ
    module Events
        class Event
            attr_accessor :market
            attr_accessor :stock
            attr_accessor :trigger
        end
        
        class CommitEvent < Event
            attr_accessor :changeset
        end
        
        class WikiCreateEvent < Event
            attr_accessor :wiki
        end
        
        class WikiPageCreateEvent < Event
            attr_accessor :page
        end
        
        class WikiPageEditEvent < Event
            attr_accessor :page
            attr_accessor :version
        end
        
        class IssueEvent < Event
            attr_accessor :issue
        end
    end
  end
end
