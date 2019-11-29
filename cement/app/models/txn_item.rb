class TxnItem < ActiveRecord::Base
  attr_accessor :buyback_was , :buyback_now
	belongs_to :transaction
	belongs_to :item
  belongs_to :contact

	after_create :stock_entry_on_create
  after_update :stock_entry_on_update
  before_destroy :stock_entry_on_destroy

    validate :all_validation
    include BaseUtils


    def all_validation
      errors.add(:item, "Select item or enter description ")  if  item_descri.blank? and item.blank?
      errors.add(:number, "Enter the quantity/no of items")   if number == 0
    end
        
	  def calculate_amount
		   self.amount = number.to_i * price.to_f
	  end	

    def stock_entry_on_create
       item_numbers =  (self.buyback_now == 1?  (self.number * -1) :self.number)
       self.item.current_stock = self.item.current_stock - item_numbers
       self.item.save!
    end  

     def stock_entry_on_update
       item_numbers =  (self.buyback_now == 1?  (self.number * -1) :self.number)
       item_numbers_was = (self.buyback_was == 1?  (self.number_was * -1) :self.number_was ) 

       diff = item_numbers - item_numbers_was
       self.item.current_stock = self.item.current_stock + diff
       self.item.save!
       update_all_stock_entry diff

    end 

    def stock_entry_on_destroy
       self.item.current_stock = self.item.current_stock + self.number
       self.item.save!
       update_all_stock_entry(-1 * self.number)
    end  

    def update_all_stock_entry diff
      
         mysql_date = Utility.mysql_date self.transaction.on_date 
         sql = "UPDATE stock_entries set item_stock = (item_stock - (#{diff}) ) "
         sql << "where item_id = #{self.item_id} and ( on_date > '#{mysql_date}' OR (on_date = '#{mysql_date}' and created_at > '#{self.updated_at}' )) "
         p sql
         ActiveRecord::Base.connection.execute(sql)      
      
    end  




     def update_total_item_stock
     end  
   
     def ui_number
        self.transaction.buyback == 1 ? (self.number * -1) : self.number
     end  

     def ui_amount
       self.transaction.buyback == 1 ? self.amount * -1 : self.amount
     end 

  class << self

    def list_by_items ids, sdate, edate
      if sdate.blank?
    	  self.where("item_id in (?)", ids)
      else
         self.where("item_id in (?) and ", ids)
      end 
    end
    
    def list_by_contacts ids, sdate, edate
    	self.where(" contact_id in (?)", ids)
    end

    def list_by_sites ids, sdate, edate
    	self.where(" site_id in (?)", ids)
    end


    def aggrigate_on_item sdate, edate
    	self.find_by_sql("select count(id)")
    end 	

    def aggrigate_on_contact sdate, edate
    end
    
    def aggrigate_on_number sdate, edate
    end 	

    def sum_amount txitems
     sum_amt = 0
      txitems.each{|s| 
        sum_amt +=  (s.transaction.buyback == 1? (-1 * s.amount.to_f) : s.amount.to_f)
      }
      return sum_amt
    end  

    def sum_itemnumers txitems
      sum_numbers = 0
      txitems.each{|s| 
        sum_numbers += ( s.transaction.buyback == 1? (-1 * s.number.to_i) : s.number.to_i)
      }
      return sum_numbers
    
    end  


    def sum_itemnumbers_amout txitems
      sum_itemnumers = sum_amt = 0
      txitems.each {|s| 
        sum_amt +=  (s.transaction.buyback == 1? (-1 * s.amount.to_f) : s.amount.to_f)
        sum_itemnumers += ( s.transaction.buyback == 1? (-1 * s.number.to_i) : s.number.to_i)
      }
      return sum_itemnumers, sum_amt
    end  

  end

end
