module Frumple
  module Econ
    class FairEconomy < BaseEconomy
        @@id = 'fair'
        @@name = 'Fair Economy'
        @@version = '0.1'
        @@author = 'Adam Meily'
        @@email = 'meily.adam@gmail.com'
        @@contribs = []
        @@description = "An economy that is fair."
        
        def initialize()
        end
        
        def on_project_create(event)
            market = Market.new(
                :project => event.project,
                :volume => 0,
                :price => 0.0
            )
            
            market.post(
                MarketHistory.new(
                    :trigger => event.trigger,
                    :dv => 0,
                    :dp => 0.20,
                    :posted => event.project.created_on
                )
            )
        end
        
        def on_user_register(event)
            stock = Stock.new(
                :user => event.user,
                :price => 0.0,
                :volume => 0,
                :last_update => event.user.created_on
            )
            
            stock.post(
                StockHistory.new(
                    :trigger => event.trigger,
                    :dp => 0.20,
                    :dv => 0,
                    :posted => event.user.created_on
                )
            )
        end
        
        def on_attachment_upload(event)
            market = hist = nil
            if event.attachment.container_type == "Project"
                market = event.attachment.container.market
            else
                market = event.attachment.container.project.market
            end
            
            if event.attachment.user
                hist = event.attachment.user.stock.post(
                    StockHistory.new(
                        :trigger => event.trigger,
                        :market => market,
                        :dv => 2,
                        :dp => 0.001,
                        :posted => event.attachment.created_on
                    )
                )
            end
            
            market.post(
                MarketHistory.new(
                    :trigger => event.trigger,
                    :dv => 2,
                    :dp => 0.001,
                    :stock_history => hist,
                    :posted => event.attachment.created_on
                )
            )
        end
        
        def on_wiki_create(event)
            market = event.wiki.project.market
            market.post(
                MaketHistory.new(
                    :trigger => event.trigger,
                    :dv => 3,
                    :dp => 0.0,
                    :posted => event.wiki.created_on
                )
            )
        end
        
        def on_wiki_page_create(event)
            market = event.wiki.project.market
            market.post(
                MarketHistory.new(
                    :trigger => event.trigger,
                    :dv => 5,
                    :dp => 0.0,
                    :posted => event.page.created_on
                )
            )
        end
        
        def on_wiki_page_edit(event)
            market = event.wiki.project.market
            hist = nil
            
            previous = nil
            event.page.content.version.each  do |v|
                previous = v
            end
            
            dv = 2
            if previous
                diff = event.version.data.length - previous.data.length
                if diff > 0
                    dv += 0.02 * diff
                end
            end
            
            if event.version.author
                stock = event.version.author.stock
                hist = stock.post(
                    StockHistory.new(
                        :trigger => event.trigger,
                        :posted => event.version.updated_on,
                        :mareket => market,
                        :dv => dv,
                        :dp => 0.03
                    )
                )
            end
            
            market.post(
                MarketHistory.new(
                    :trigger => event.trigger,
                    :posted => event.version.updated_on,
                    :dv => dv,
                    :dp => 0.03,
                    :stock_history => hist
                )
            )
        end
        
        def on_repo_commit(event)
            hist = nil
            market = event.changeset.project.market
            dp = 0.01 + (0.005 * event.changeset.issues.length)
            
            if event.changeset.user
                hist = event.changeset.committer.stock.post(
                    StockHistory.new(
                        :trigger => event.trigger,
                        :dv => 1,
                        :dp => dp,
                        :market => market,
                        :posted => event.changeset.committed_on
                    )
                )
            end
            
            market.post(
                MarketHistory.new(
                    :trigger => event.trigger,
                    :dv => 1,
                    :dp => dp,
                    :stock_history => hist,
                    :posted => event.changeset.committed_on
                )
            )
        end
        
    end
  end
end
