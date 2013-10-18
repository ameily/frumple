namespace :frumple do
  namespace :import do
    desc "Initialize frumple from existing data"
    task :all => [:projects, :users, :repos, :attachments]
    
    desc "Create Markets from Projects"
    task :projects => :environment do
        Market.delete_all
        MarketHistory.delete_all
        
        puts "Importing Projects..."
        Project.find_each do |project|
            Market.create(
                :project => project,
                :volume => 0,
                :price => 0.20,
                :last_update => project.created_on
            )
        end
    end
    
    desc "Create Stocks from Users"
    task :users => :environment do
        Stock.delete_all
        StockHistory.delete_all
        
        puts "Importing Users..."
        User.find_each do |user|
            Stock.create(
                :user => user,
                :volume => 0,
                :price => 0.20,
                :last_update => user.created_on
            )
        end
    end
    
    desc "Import Repositories"
    task :repos => :environment do
        puts "Importing Repos..."
        objs = [ ]
        repos = { }
        Repository.find_each do |repo|
            repos[repo.id] = repo.project.market
        end
        
        puts "==> Importing Changesets..."
        Changeset.find_each do |cs|
            dv = 1
            dp = 0.01
            action = "repo.commit.#{cs.revision}"
            market = repos[cs.repository_id]
            
            dp += 0.005 * cs.issues.length
            
            stock_id = nil
            if cs.user_id
                stock = cs.user.stock
                stock_id = stock.id
                objs << StockHistory.new(
                    :action => action,
                    :dv => dv,
                    :dp => dp,
                    :stock => stock,
                    :posted => cs.committed_on
                )
            end
            
            objs << MarketHistory.create(
                :action => action,
                :stock_id => stock_id,
                :market => market,
                :dv => dv,
                :dp => dp,
                :posted => cs.committed_on
            )
        end
        
        puts "==> Saving stock/market history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
            end
        end
    end
    
    desc "Import Attachments"
    task :attachments => :environment do
        puts "Importing Attachments..."
        Attachment.find_each do |attach|
            dv = 2
            dp = 0.001
            action = "attachment.#{attach.id}.create"
            stock_id = nil
            
            if attach.author_id
                stock = attach.author.stock
                StockHistory.create(
                    :action => action,
                    :dv => dv,
                    :dp => dp,
                    :stock => stock,
                    :posted => attach.created_on
                )
            end
            
            project = nil
            if attach.container_type == 'Project'
                project = attach.container
            elsif attach.container
                project = attach.container.project
            end
            
            if project
                MarketHistory.create(
                    :action => action,
                    :dv => dv,
                    :dp => dp,
                    :stock_id => stock_id,
                    :posted => attach.created_on,
                    :market => project.market
                )
            end
        end
    end
    
    desc "Import Wiki Pages"
    task :wiki => :environment do
        puts "Importing Wikis..."
        objs = [ ]
        wikis = { }
        Wiki.find_each do |wiki|
            dp = 0.0
            dv = 3
            objs << MarketHistory.new(
                :action => 'wiki.create',
                :dv => dv,
                :dp => dp,
                :stock_id => nil,
                :posted => wiki.project.created_on,
                :market => wiki.project.market
            )
            
            wikis[wiki.id] = wiki
        end
        
        puts "==> Importing Pages..."
        WikiPage.find_each do |page|
            dv = 5
            dp = 0.0
            wiki = wikis[page.wiki_id]
            objs << MarketHistory.new(
                :action => "wiki.page.#{page.title}.create",
                :dv => dv,
                :dp => dp,
                :stock_id => nil,
                :posted => page.created_on,
                :market => wiki.project.market
            )
            
            
            items = [ ]
            dv = 2
            dp = 0.03
            ddv = 0.02
            page.content.versions.each do |version|
                if version.compression == ''
                    len = version.data.length
                    diff = 0
                    if items.empty?
                        diff = len
                    else
                        diff = len - items.last[:len]
                    end
                    
                    if diff > 0
                        items << {
                            :diff => diff,
                            :len => len,
                            :stock => version.author.stock,
                            :posted => version.updated_on,
                            :id => version.id
                        }
                    end
                end
            end
            
            items.each do |i|
                action = "wiki.page.#{page.title}.version.#{i[:id]}{delta=#{i[:diff]}}"
                v = dv + (ddv * i[:diff])
                objs << MarketHistory.new(
                    :action => action,
                    :dv => v,
                    :dp => dp,
                    :posted => i[:posted],
                    :stock_id => i[:stock].id,
                    :market => wiki.project.market
                )
                
                objs << StockHistory.new(
                    :action => action,
                    :dv => v,
                    :dp => dp,
                    :stock => i[:stock],
                    :posted => i[:posted]
                )
            end
        end
        
        puts "==> Saving stock/market history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
            end
        end
    end
    
    desc "Import Issues"
    task :issues => :environment do
        objs = [ ]
        puts "Importing Issues..."
        Issue.find_each do |issue|
            market = issue.project.market
            stock = issue.author.stock
            action = "issue.#{issue.id}.create"
            dvs = {
                "Feature" => 5,
                "Support" => 3,
                "Bug" => 10
            }
            
            dps = {
                "Feature" => 0.07,
                "Bug" => 0.10,
                "Support", 0.5
            }
            
            dv = dvs[issue.tracker.name]
            dp = dps[issue.tracker.name]
            
            objs << MarketHistory.new(
                :market => market,
                :stock_id => stock_id,
                :dv => dv,
                :dp => dp,
                :action => action,
                :posted => issue.created_on
            )
            
            objs << StockHistory.new(
                :stock => stock,
                :dv => dv,
                :dp => dp,
                :action => action,
                :posted => issue.created_on
            )
            
            # TODO journals (straight content)
            # TODO journal details (meta: assignment, and whatnot)
        end
        
        puts "==> Saving stock/market history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
            end
        end
    end
    
    # TODO versions
    # TODO documents
    
  end
end
