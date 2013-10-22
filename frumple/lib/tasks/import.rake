namespace :frumple do
  namespace :import do
    desc "Initialize frumple from existing data"
    task :all => [:projects, :users, :repos, :attachments, :wiki]
    
    
    
    # TODO versions
    # TODO documents
    
  end
end
