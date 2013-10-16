class Market < ActiveRecord::Base
  belongs_to :project
  has_many :history, :foreign_key => 'market_id', :class_name => 'MarketHistory'
  
  def gdp
    self[:price] * self[:volume]
  end
  
  def gni
    sum = self.gdp
    Project.where(parent_id: self[:project_id]).each do |subp|
      subm = Market.where(project_id: subp.id).first
      if subm
        sum += subm.gni
      end
    end
    sum
  end
end

