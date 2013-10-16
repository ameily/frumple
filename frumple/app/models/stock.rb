class Stock < ActiveRecord::Base
  belongs_to :user
  has_many :history, :foreign_key => 'stock_id', :class_name => 'StockHistory'
  
  def value
    self[:volume] * self[:price]
  end
end
