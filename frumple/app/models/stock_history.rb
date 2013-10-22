class StockHistory < ActiveRecord::Base
  belongs_to :stock
  belongs_to :market
  has_one :market_history
  belongs_to :parent, :class_name => 'StockHistory'
  has_many :children, :foreign_key => 'parent_id', :class_name => 'StockHistory'
end
