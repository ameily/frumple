module Frumple
  module Econ
    class FairEconomy < BaseEconomy
        @@id = "fair"
        @@name = "Fair Economy"
        @@version = "0.1"
        @@author = "Adam Meily"
        @@email = "meily.adam@gmail.com"
        @@contribs = []
        @@description = "An economy that is fair."
        
        def initialize()
        end
        
        def post(hists)
            if hists[:stock]
                hists[:stock].post(true)
            end
            
            if hists[:market]
                hists[:market].post(true)
            end
        end
        
        def create_histories(event, ds = { :dv => 0, :dp => 0.0 }, dm = { :dv => 0, :dp => 0.0 })
            sh = mh = nil
            
            if event.stock
                sh = StockHistory.new(
                    :market => event.market,
                    :stock => event.stock,
                    :dv => ds[:dv],
                    :dp => ds[:dp],
                    :posted => event.timestamp,
                    :trigger => event.trigger
                )
            end
            
            if event.market
                mh = MarketHistory.new(
                    :market => event.market,
                    :stock_history => sh,
                    :dv => dm[:dv],
                    :dp => dm[:dp],
                    :posted => event.timestamp,
                    :trigger => event.trigger
                )
            end
            
            { :stock => sh, :market => mh }
        end
        
        def on_project_create(event)
            market = Market.create(
                :project => event.project,
                :volume => 0,
                :price => 0.0
            )
            
            market.post(
                MarketHistory.new(
                    :trigger => event.trigger,
                    :dv => 0,
                    :dp => 0.20,
                    :posted => event.timestamp
                )
            )
        end
        
        def on_user_register(event)
            stock = Stock.create(
                :user => event.user,
                :price => 0.0,
                :volume => 0,
                :last_update => event.timestamp
            )
            
            stock.post(
                StockHistory.new(
                    :trigger => event.trigger,
                    :dp => 0.20,
                    :dv => 0,
                    :posted => event.timestamp
                )
            )
        end
        
        def on_attachment_upload(event)
            deltas = { :dv => 2, :dp => 0.001 }
            hists = self.create_histories(event, deltas, deltas)
            self.post(hists)
        end
        
        def on_attachment_delete(event)
            deltas = { :dv => -2, :dp => -0.001 }
            hists = self.create_histories(event, deltas, deltas)
            self.post(hists)
        end
        
        def on_wiki_create(event)
            self.post(
                self.create_histories(
                    event, nil, { :dv => 3, :dp => 0.0 }
                )
            )
        end
        
        def on_wiki_page_create(event)
            self.post(
                self.create_histories(
                    event, nil, { :dv => 5, :dp => 0.0 }
                )
            )
        end
        
        def on_wiki_page_edit(event)
            market = event.wiki.project.market
            hist = nil
            
            previous = current = nil
            event.page.content.versions.each do |v|
                previous = current
                current = v
                if current.id == event.version.id
                    break
                end
            end
            
            
            deltas = { :dv => 1, :dp => 0 }
            if previous
                diff = event.version.data.length - previous.data.length
                if diff > 0
                    #deltas[:dv] += 0.02 * diff
                end
            end
            
            self.post(
                self.create_histories(
                    event, deltas, deltas
                )
            )
        end
        
        def on_repo_commit(event)
            hist = nil
            deltas = { :dv => 1, :dp => 0.01 }
            deltas[:dp] += 0.005 * event.changeset.issues.length
            
            self.post(
                self.create_histories(
                    event, deltas, deltas
                )
            )
        end
        
        def on_issue_create(event)
        end

        def on_issue_delete(event)
        end

        def on_issue_reassign(event)
        end

        def on_issue_status_change(event)
            if event.to_status.is_closed
                # TODO is rejected = closed?
            end
        end
    end
  end
end
