
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
            
            def fire()
                if self.market
                    self.market.dispatch(self)
                end
            end
        end
        
        class ProjectEvent < Event
            attr_accessor :project
        end
        
        class ProjectCreateEvent < ProjectEvent
            def initialize(project)
                @project = project
                @market = nil
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
                @stock = nil
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
        
        ###### Journal Events #######

        class JournalEvent < Event
            attr_accessor :journal
        end
        
        class JournalDetailEvent < Event
            attr_accessor :detail
            attr_accessor :journal
        end

        class JournalDetailCreateEvent < JournalDetailEvent
            def initialize(detail)
                @timestamp = detail.created_on
                @detail = detail
                @journal = @detail.journal
                @stock = @journal.user.stock
                @market = @journal.project.market
            end

            def self.Spec(detail)
                case detail.journalized_type
                when 'Issue'
                    return IssueJournalCreateEvent.Spec(detail)
                else
                    return nil
                end
            end
        end

        class IssueJournalDetailCreateEvent < JournalDetailCreateEvent
            attr_accessor :issue
            def initialize(detail)
                super(detail)
                @issue = @journal.issue
            end

            def self.Spec(detail)
                case detail.prop_key
                when "status_id"
                    return IssueStatusChangeEvent.new(detail)
                when "assigned_to_id"
                    return IssueReassignEvent.new(detail)
                else
                    return nil
                end
            end
        end
        
        class IssueReassignEvent < IssueJournalDetailCreateEvent
            attr_accessor :from_user
            attr_accessor :to_user

            def initialize(detail)
                super(detail)
                @from_user = @detail.old_value ? User.find(@detail.old_value) : nil
                @to_user = @detail.value ? User.find(@detail.value) : nil
                @trigger = "issue.#{@issue.id}.reassign"
            end
        end
        
        class IssueStatusChangeEvent < IssueJournalDetailCreateEvent
            attr_accessor :from_status
            attr_accessor :to_status
            def initialize(detail)
                super(detail)
                @from_status = @detail.old_value ? IssueStatus.find(detail.old_value) : nil
                @to_status = detail.value ? IssueStatus.find(detail.value) : nil
                @trigger = "issue.#{@issue.id}.status.#{@to_status.name}"
            end
        end
        
        class IssueEvent < Event
            attr_accessor :issue
        end
        
        class IssueCreateEvent < IssueEvent
            def initialize(issue)
                @issue = issue
                @trigger = "issue.create.#{issue.id}"
                @stock = issue.author.stock
                @market = issue.project.market
                @timestamp = issue.created_on
            end
        end

        class IssueDeleteEvent < IssueEvent
            def initialize(issue)
                @issue = issue
                @trigger = "issue.delete.#{@issue.id}"
                @stock = issue.author.stock
                @market = issue.project.market
                @timestamp = DateTime.now()
            end
        end
    end
  end
end
