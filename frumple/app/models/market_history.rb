class MarketHistory < ActiveRecord::Base
  belongs_to :market
  belongs_to :stock_history
end
