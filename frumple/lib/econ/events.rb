
module Frumple
  module Econ
    module Events
        class Event
            #attr_accessor :market
            #attr_accessor :stock
            attr_accessor :trigger
            attr_accessor :market
            attr_accessor :stock
            attr_accessor :timestamp
        end
        
        class ProjectEvent < Event
            attr_accessor :project
        end
        
        class ProjectCreateEvent < ProjectEvent
            def initialize(project)
                @project = project
                @market = project.market
                @stock = nil
                @timestamp = project.created_on
                @trigger = 'project.create'
            end
        end
        
        class UserEvent < Event
            attr_accessor :user
        end
        
        class UserRegisterEvent < UserEvent
            def initialize(user)
                @user = user
                @stock = user.stock
                @market = nil
                @timestamp = user.created_on
                @trigger = "user.register"
            end
        end
        
        class AttachmentEvent < Event
            attr_accessor :attachment
            attr_accessor :market
            attr_accessor :stock
            
            def initialize(attachment)
                @attachment = attachment
                
                if attachment.author
                    @stock = attachment.author.stock
                else
                    @stock = nil
                end
                
                if attachment.container
                    @market = attachment.project.market
                else
                    @market = nil
                end
            end
        end
        
        class AttachmentUploadEvent < AttachmentEvent
            def initialize(attachment)
                super(attachment)
                
                @timestamp = attachment.created_on
                @trigger = "attachment.upload.#{attachment.id}"
            end
        end
        
        class AttachmentDeleteEvent < AttachmentEvent
            def initialize(attachment)
                super(attachment)
                
                @timestamp = DateTime.now()
                @trigger = "attachment.delete.#{attachment.id}"
            end
        end
        
        class RepoEvent < Event
            attr_accessor :repo
        end
        
        class RepoCommitEvent < RepoEvent
            attr_accessor :changeset
            
            def initialize(changeset)
                @repo = changeset.repository
                @timestamp = changeset.committed_on
                
                if @repo and @repo.project
                    @market = @repo.project.market
                else
                    @market = nil
                end
                #if @repo.project
                #    @market = @repo.project.market
                #else
                #    @market = nil
                #end
                
                if changeset.user
                    @stock = changeset.user.stock
                else
                    @stock = nil
                end
                
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
                @market = wiki.project.market
                @stock = nil
                @timestamp = wiki.project.created_on
                @trigger = "wiki.create.#{wiki.id}"
            end
        end
        
        class WikiPageCreateEvent < WikiEvent
            attr_accessor :page
            
            def initialize(page)
                @wiki = page.wiki
                @market = @wiki.project.market
                @stock = nil
                @timestamp = page.created_on
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
                @market = @wiki.project.market
                
                if not version.author.nil?
                    @stock = version.author.stock
                else
                    @stock = nil
                end
                
                @timestamp = version.updated_on
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
