namespace :frumple do
  namespace :import do
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
  end
end
