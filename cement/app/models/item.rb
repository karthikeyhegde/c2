class Item < ActiveRecord::Base
  # attr_accessible :title, :body
   has_many :txn_items
   before_create :assign_stock
   before_update :update_stock

  include BaseUtils




def assign_stock
  self.current_stock = self.starting_stock
end  
 
  def update_stock
     if starting_stock_changed?
        diff = starting_stock - starting_stock_was
        self.current_stock += diff
        sql = "UPDATE  stock_entries set item_stock = (item_stock + (#{diff}) ) "
        sql << "where item_id = #{self.id} "
        ActiveRecord::Base.connection.execute(sql)      
     end
  end

  def list_by_contacts
  end
  
  def get_by_number_of_items
  end	

  def recalculate_current_stock back_date
      tx_items = rep_ixnitems back_date, nil, 50000
      t_num, t_amt = TxnItem.sum_itemnumbers_amout tx_items
      

  end  


  def rep_ixnitems sdate = nil, edate=nil, limit = 5000
     sdate = "1999-01-01" if sdate.nil?
     edate = "2100-01-01" if edate.nil?
     sql_str =  " select ti.*,t.on_date,t.id from txn_items ti , transactions t where ti.transaction_id = t.id "
     sql_str << " and t.on_date  between '#{sdate}' and '#{edate}' " 
     sql_str << " and item_id = #{self.id} order by t.on_date desc  limit #{limit} "
     TxnItem.find_by_sql(sql_str)
  end	


  def update_stockentry_fromdate
 
    ittxns = rep_ixnitems self.start_date, nil, 50000
    txnsum = TxnItem.sum_itemnumers ittxns
    stocksum =  calculate_stockentry_sum 
    self.current_stock = stocksum + starting_stock - txnsum
    self.save!

  end  


  def calculate_stockentry_sum
     sentries = StockEntry.where(' item_id = ? and created_at > ?',self.id,self.start_date)
      sum = 0
      sentries.each{|s| 
       sum += (s.is_return == 1? (s.numbers * -1) : s.numbers)
      }
      return sum
  end  


  def self.mass_update_currentstock
      @default_date = MySetting.find_by_name('stock_start_date')
     dt = DateTime.parse(@default_date.value).strftime("%d-%m-%Y %H:%M:%S")
    ndt = DateTime.parse(dt).strftime("%Y-%m-%d %H:%M:%S")
        sql = "UPDATE  items set start_date = '#{ndt}'"
        ActiveRecord::Base.connection.execute(sql)   

      Item.all.each{|it|
        p it.name
       it.update_stockentry_fromdate
      }
  end  


  def self.picklist
     arr = []
     self.order("name, description").each{|a|

      p_name =  ( a.description.blank? ? a.name : a.name+", "+a.description)
      arr << [p_name, a.id]
     }
     return arr
  end  


  def aggrigated_list hash

    from_date = hash["from_date"]
    to_date = hash["to_date"] 
    site_id = hash["site_id"]
    contact_id = hash["contact_id"]
    item_id = hash["item_id"]
    f_date =  from_date.blank? ? '' : DateTime.parse(from_date).strftime('%Y-%m-%d %H:%M')  
    t_date =  to_date.blank?  ?  '' : DateTime.parse(to_date).strftime('%Y-%m-%d %H:%M') unless to_date.blank?
    weekly =  hash["weekly"]
    monthly = hash["monthly"]


  end  

  def self.summary  hash

    from_date = hash["from_date"]
    to_date = hash["to_date"] 
    site_id = hash["site_id"]
    contact_id = hash["contact_id"]

    f_date =  from_date.blank? ? '' : DateTime.parse(from_date).strftime('%Y-%m-%d %H:%M')  
    t_date =  to_date.blank?  ?  '' : DateTime.parse(to_date).strftime('%Y-%m-%d %H:%M') unless to_date.blank?
    

    sql =  " Select itm.name,sum(if(txn.buyback = 1, txnitm.amount * -1, txnitm.amount)) as t_sum,"
    sql << " sum(if(txn.buyback = 1, txnitm.number * -1, number)) as t_no "
    sql << " from txn_items txnitm, transactions txn, items itm "  
    sql << " where txnitm.transaction_id = txn.id and txnitm.item_id =itm.id "
    sql << " and txn.contact_id = #{contact_id.to_i} " if contact_id.to_i != 0
    sql << " and txn.site_id = #{site_id.to_i} " if site_id.to_i != 0
    sql << " and txn.on_date >  '#{f_date}' " if !f_date.blank?
    sql << " and txn.on_date < '#{to_date}' "  if !t_date.blank?
    sql << " group by txnitm.item_id  "
    self.find_by_sql(sql)

  end  


  def self.rep_txnitems id
    item = Item.find(id.to_i)
    txn_items = @item.rep_ixnitems
    all_sum = 0
    @all_numbers = 0
    @txn_items.each{|s| 
      @all_sum +=  (s.transaction.buyback == 1 ? (-1 * s.amount.to_f) : s.amount.to_f)
      @all_numbers += ( s.transaction.buyback == 1 ? (-1 * s.number.to_i) : s.number.to_i)
    }
  end  

  

  def self.color_code i=null
     ccode = ["", #26CEBF",
"#F2B54D",
"#E8ACE9",
"#ADEC6E",
"#F99394",
"#6AC2F2",
"#BCD395",
"#6DEFA6",
"#C8E3E8",
"#F2E95D",
"#E3AF76",
"#E7C9DF",
"#EF95BA",
"#75C69C",
"#9DEAD6",
"#87C270",
"#9CB1EC",
"#C3BB6B",
"#8AB1C4",
"#53F7CF",
"#E0F380",
"#4FD7F2",
"#F0B0A6",
"#9FC29F",
"#DCCC5F",
"#B4F1C3",
"#EF9C66",
"#E2EC96",
"#C8F7AE",
"#D0B7E5",
"#46E3E8",
"#CBD4EF",
"#46CF9E",
"#3DF6E6",
"#D1EC5F",
"#DDD292",
"#ADC56D",
"#8AC6BC",
"#E7ABB8",
"#F4A68C",
"#9DDFEA",
"#B1D363",
"#99E880",
"#9DEEAB",
"#9BCDEF",
"#B4C0C9",
"#CFAE5D",
"#73D091",
"#CAEF8D",
"#A5E191",
"#9FD499",
"#8DEEC5",
"#74BFD2",
"#E8CE7F",
"#A5B9E2",
"#79DCDF",
"#76EFDF",
"#C0B579",
"#C6CE5A",
"#EEC759",
"#86D9F5",
"#7AE890",
"#A8CCDE",
"#5EF5BC",
"#46D3B3",
"#BAEADC",
"#8BD0B1",
"#EFA5CF",
"#F4AE59",
"#5DD5C2"];

  return ccode[i] if i != nil and i.to_i > 0
  return ccode

  end  
  


end
