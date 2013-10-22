namespace :frumple do
  namespace :import do
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
  end
end
