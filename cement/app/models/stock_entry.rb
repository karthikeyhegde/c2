
class StockEntry < ActiveRecord::Base
    attr_accessor :diff
    belongs_to :item
    belongs_to    :contact


    before_save :calc_entry_stock
    after_save  :calc_item_current_stock
    after_update :update_calc_stock
    after_destroy :destroy_stock_update


    def name_subname
      return (contact.blank? ? "" : contact.name_subname)
    end  

    
    def calc_item_current_stock
      se_numbers =  (is_return == 1? (self.numbers * -1) : self.numbers)
   	  self.item.current_stock = self.item.current_stock + se_numbers
   	  self.item.save!
    end

    def calc_entry_stock
       se_numbers =  (is_return == 1? (self.numbers * -1) : self.numbers)	
   	   self.item_stock = self.item.current_stock + se_numbers	   
    end	

    def update_calc_stock  
	      se_numbers =  (is_return == 1? (self.numbers * -1) : self.numbers)
	      se_numbers_was =  (self.is_return_was == 1? (self.numbers_was * -1) : self.numbers_was) 
	      diff = se_numbers.to_i - se_numbers_was.to_i
	   	  stock_update diff  if diff != 0
    end	

    def destroy_stock_update
      stock_upadate(self.numbers * -1)
    end  

    def stock_upadate diff
	    self.item.current_stock = self.item.current_stock + diff
   	  self.item.save!
   	  mysql_date = Utility.mysql_date on_date 
      sql =  "  UPDATE stock_entries set item_stock =  item_stock + #{diff} "
      sql << " where item_id = #{self.item_id} and ( on_date > '#{mysql_date}' OR (on_date = '#{mysql_date}' and created_at > '#{self.created_at}' ))"
      ActiveRecord::Base.connection.execute(sql)
    end	

    def self.list
      from_date = hash["from_date"]
      to_date = hash["to_date"] 
      contact_id = hash["contact_id"]
      item_id = hash["item_id"]

      
     f_date =  from_date.blank? ? '' : DateTime.parse(from_date).strftime('%Y-%m-%d %H:%M')  
     t_date =  to_date.blank?  ?  '' : DateTime.parse(to_date).strftime('%Y-%m-%d %H:%M') unless to_date.blank?

    sql = "SELECT * "
    sql << " from stock_entries txn "  
    sql << " where 1 = 1 "
    sql << "and txn.contact_id = #{contact_id.to_i} " if contact_id.to_i != 0
    sql << " and txn.site_id = #{site_id.to_i} " if site_id.to_i != 0
    sql << " and txn.item_id = #{item_id.to_i} " if item_id.to_i != 0
    sql << " and txn.on_date >  '#{f_date}' " if !f_date.blank?
    sql << " and txn.on_date < '#{to_date}' "  if !t_date.blank?
    self.find_by_sql(sql)

    end  

    def self.calculate_item_sum sentries
      sum = 0
      sentries.each{|s| 
       sum += (s.is_return == 1? (s.numbers * -1) : s.numbers)
      }
      return sum
    end

    


end	