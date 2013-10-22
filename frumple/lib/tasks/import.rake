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
            trigger = "repo.commit.#{cs.revision}"
            market = repos[cs.repository_id]
            
            dp += 0.005 * cs.issues.length
            
            stock_history = nil
            if cs.user_id
                stock = cs.user.stock
                stock_history = StockHistory.new(
                    :trigger => trigger,
                    :market => market,
                    :dv => dv,
                    :dp => dp,
                    :stock => stock,
                    :posted => cs.committed_on
                )
                objs << stock_history
            end
            
            objs << MarketHistory.create(
                :trigger => trigger,
                :stock_history => stock_history,
                :market => market,
                :dv => dv,
                :dp => dp,
                :posted => cs.committed_on
            )
        end
        
        puts "==> Saving history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
            end
        end
    end
    
    desc "Import Attachments"
    task :attachments => :environment do
        puts "Importing Attachments..."
        objs = [ ]
        Attachment.find_each do |attach|
            dv = 2
            dp = 0.001
            trigger = "attachment.#{attach.id}.create"
            
            market = nil
            if attach.container_type == 'Project'
                market = attach.container.market
            elsif attach.container
                market = attach.container.project.market
            end
            
            stock_history = nil
            if attach.author_id
                stock_history = StockHistory.new(
                    :trigger => trigger,
                    :market => market,
                    :dv => dv,
                    :dp => dp,
                    :stock => attach.author.stock,
                    :posted => attach.created_on
                )
                objs << stock_history
            end
            
            if market.nil?
                objs << MarketHistory.new(
                    :trigger => trigger,
                    :dv => dv,
                    :dp => dp,
                    :stock_history => stock_history,
                    :posted => attach.created_on,
                    :market => market
                )
            end
        end
        
        puts "==> Saving history..."
        MarketHistory.transaction do
            objs.each do |obj|
                obj.save(:validate => false)
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
                :trigger => 'wiki.create',
                :dv => dv,
                :dp => dp,
                :stock_history => nil,
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
                :trigger => "wiki.page.#{page.title}.create",
                :dv => dv,
                :dp => dp,
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
                trigger = "wiki.page.#{page.title}.version.#{i[:id]}{delta=#{i[:diff]}}"
                v = dv + (ddv * i[:diff])
                sh = StockHistory.new(
                    :trigger => trigger,
                    :dv => v,
                    :dp => dp,
                    :stock => i[:stock],
                    :posted => i[:posted]
                )
                objs << sh
                
                objs << MarketHistory.new(
                    :trigger => trigger,
                    :dv => v,
                    :dp => dp,
                    :posted => i[:posted],
                    :stock_history => sh,
                    :market => wiki.project.market
                )
            end
        end
        
        puts "==> Saving history..."
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
            trigger = "issue.#{issue.id}.create"
            dvs = {
                "Feature" => 5,
                "Support" => 3,
                "Bug" => 10
            }
            
            dps = {
                "Feature" => 0.07,
                "Bug" => 0.10,
                "Support" => 0.5
            }
            
            dv = dvs[issue.tracker.name]
            dp = dps[issue.tracker.name]
            
            objs << MarketHistory.new(
                :market => market,
                :stock_id => stock_id,
                :dv => dv,
                :dp => dp,
                :trigger => trigger,
                :posted => issue.created_on
            )
            
            objs << StockHistory.new(
                :stock => stock,
                :dv => dv,
                :dp => dp,
                :trigger => trigger,
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
