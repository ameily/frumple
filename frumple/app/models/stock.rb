class Stock < ActiveRecord::Base
  belongs_to :user
  has_many :history, :foreign_key => 'stock_id', :class_name => 'StockHistory'
  
  def value
    self[:volume] * self[:price]
  end
  
    def post(history)
        history.stock = self
        history.volume = (self.volume += history.dv)
        history.price = (self.price += history.dp)
        
        if self.last_update.nil? or history.posted > self.last_update
            self.last_update = history.posted
        end
        
        self.save({ :validate => false })
        history.save({ :validate => false })
        
        history
    end
end
