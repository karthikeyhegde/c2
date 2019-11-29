class Site < ActiveRecord::Base
  # attr_accessible :title, :body
#  audited
  has_many :contacts
  has_many :transactions
  validates_presence_of :name



  def rep_txnitems contact_id = nil

  	sql = "select ti.*,t.on_date,t.site_id from txn_items ti,transactions t where ti.transaction_id = t.id "
  	sql << " and t.contact_id = #{contact_id} " if  !contact_id.nil?
    sql << " and t.site_id = #{self.id} order by t.on_date desc " 
    
    TxnItem.find_by_sql(sql)
    
  end	

  def self.picklist
     arr = []
     self.order("name").each{|a|

      
      arr << [a.name, a.id]
     }
     return arr
  end  

  
end
