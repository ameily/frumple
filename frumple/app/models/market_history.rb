class MarketHistory < ActiveRecord::Base
  belongs_to :market
  belongs_to :stock_history
  
  def post(reload = false)
      if reload
        self.market.reload()
      end
      self.market.post(self)
  end
  
end
