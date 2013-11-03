module Frumple
  module Econ
    class BaseEconomy
        def dispatch(event)
            case event
            when Events::ProjectCreateEvent
                self.on_project_event(event)
            when Events::UserEvent
                self.on_user_event(event)
            when Events::AttachmentEvent
                self.on_attachment_event(event)
            when Events::RepoEvent
                self.on_repo_event(event)
            when Events::WikiEvent
                self.on_wiki_event(event)
            when Events::IssueEvent
                self.on_issue_event(event)
            else
                raise NotImplementedError
            end
        end
        
        # User Events
        def on_user_event(event)
            case event
            when Events::UserRegisterEvent
                self.on_user_register(event)
            else
                raise NotImplementedError
            end
        end
        
        def on_user_register(event)
            raise NotImplementedError
        end
        
        # Project Events
        def on_project_event(event)
            case event
            when Events::ProjectCreateEvent
                self.on_project_create(event)
            else
                raise NotImplementedError
            end
        end
        
        def on_project_create(event)
            raise NotImplementedError
        end
        
        # Attachment Events
        def on_attachment_event(event)
            case event
            when Events::AttachmentUploadEvent
                self.on_attachment_upload(event)
            when Events::AttachmentDeleteEvent
                self.on_attachment_delete(event)
            else
                raise NotImplementedError
            end
        end
        
        def on_attachment_upload(event)
            raise NotImplementedError
        end
        
        def on_attachment_delete(event)
            raise NotImplementedError
        end
        
        # Wiki Events
        def on_wiki_event(event)
            case event
            when Events::WikiCreateEvent
                self.on_wiki_create(event)
            when Events::WikiPageCreateEvent
                self.on_wiki_page_create(event)
            when Events::WikiPageEditEvent
                self.on_wiki_page_edit(event)
            else
                raise NotImplementedError
            end
        end
        
        def on_wiki_create(event)
            raise NotImplementedError
        end
        
        def on_wiki_page_create(event)
            raise NotImplementedError
        end
        
        def on_wiki_page_edit(event)
            raise NotImplementedError
        end
        
        # Repo Events
        def on_repo_event(event)
            case event
            when Events::RepoCommitEvent
                self.on_repo_commit(event)
            else
                raise NotImplementedError
            end
        end
        
        def on_repo_commit(event)
            raise NotImplementedError
        end
        
        # Issue Events
        def on_issue_event(event)
            raise NotImplementedError
        end
    end
  end
end
