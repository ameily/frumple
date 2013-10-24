
module Frumple
  module Econ
    module Events
        class Event
            #attr_accessor :market
            #attr_accessor :stock
            attr_accessor :trigger
        end
        
        class ProjectEvent < Event
            attr_accessor :project
        end
        
        class ProjectCreateEvent < ProjectEvent
            def initialize(project)
                @project = project
                @trigger = 'project.create'
            end
        end
        
        class UserEvent < Event
            attr_accessor :user
        end
        
        class UserRegisterEvent < UserEvent
            def initialize(user)
                @user = user
                @trigger = "user.register"
            end
        end
        
        class AttachmentEvent < Event
            attr_accessor :attachment
        end
        
        class AttachmentUploadEvent < AttachmentEvent
            def initialize(attachment)
                @attachment = attachment
                @trigger = "attachment.upload.#{attachment.id}"
            end
        end
        
        class RepoEvent < Event
            attr_accessor :repo
        end
        
        class RepoCommitEvent < RepoEvent
            attr_accessor :changeset
            
            def initialize(changeset)
                @repo = changeset.repository
                @changeset = changeset
                @trigger = "repo.commit.#{changeset.id}"
            end
        end
        
        class WikiEvent < Event
            attr_accessor :wiki
        end
        
        class WikiCreateEvent < WikiEvent
            def initialize(wiki)
                @wiki = wiki
                @trigger = "wiki.create.#{wiki.id}"
            end
        end
        
        class WikiPageCreateEvent < WikiEvent
            attr_accessor :page
            
            def initialize(page)
                @wiki = page.wiki
                @page = page
                @trigger = "wiki.page.create.#{page.id}"
            end
        end
        
        class WikiPageEditEvent < WikiEvent
            attr_accessor :page
            attr_accessor :version
            
            def initialize(version)
                @page = version.page
                @wiki = @page.wiki
                @version = version
                @trigger = "wiki.page.edit.#{version.id}"
            end
        end
        
        class IssueEvent < Event
            attr_accessor :issue
        end
    end
  end
end
