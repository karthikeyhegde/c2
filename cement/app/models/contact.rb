
class Contact < ActiveRecord::Base
  
  include BaseUtils
  audited :allow_mass_assignment => true
  
 # attr_accessible :name_subname
  has_many :sites
  has_many :transactions
  has_many :payments
  
  #before_create :assign_balance
  #after_update  :rectify_contact_balance

 # before_update  :rectify_contact_balance

  validates :name, :presence => { :message => " Cannot be blank" }
  validates :name, uniqueness: { scope: :subname,
  message: "Contact already exists. Try with different name or tag name" }

  def unique_contact

    if Contact.exists?(:name => self.name, :subname => self.subname)
     errors.add(:base,"Contacts already exists, try with different name or tag name") 
    end
  end  

  def name_subname
    return subname.blank? ? name : name+ " "+subname
  end 

  def name_subname_underscore
     gname = name.gsub(' ','_')
     gsname = subname.to_s.gsub(' ','_')
     return subname.blank? ? gname : gname+ " "+gsname
  end 

  def parent
   Contact.find(self.parent_id) unless self.parent_id.blank?
  end

  def self.trns_search(str)
  	s_contacts = self.where("name  like '#{str}%' or subname  like '#{str}%' ").select('id,name,subname,contact_number').order('name asc')
  end	

  def self.all_conts
     select('id,name,subname,contact_number,balance').order('name asc')
  end

  def total_purchase
    t_amount = 0.0
    self.transactions.each{|t| 

      t_amount -= t.amount.to_f  if t.buyback == 1
      t_amount += t.amount.to_f  if t.buyback != 1

    }
    return t_amount
  end  

  def total_payment
    t_amount = 0.0
    self.transactions.each{|p| 
      t_amount += p.payment_amount.to_f if p.recieved == 1
      t_amount -= p.payment_amount.to_f if p.recieved != 1
    }
    return t_amount
  end  


  def self.paginated_search(p_hash)
    col     = ( p_hash[:column].blank? ?  'id' : p_hash[:column])
    value   = ( p_hash[:value].blank? ?  '' : p_hash[:value])  
    limit   = ( p_hash[:limit].to_i = 0 ? '50' :  p_hash[:limit].to_i)
    order   = ( p_hash[:order].blank? ?  'id' : params[:order])
    offstet =   p_hash[:offset].to_i 

    order_str = params[:order]
    order_str  = 'id'  if order.blank?
    order_str =  "#{order[1..(order.lenght-1)]},desc" if order[0,1] == "-"
    offset = (total_count/page_no) - 1
    total_count = self.where("#{columns} like '%?%'",values).count if total_count.nil?
    contacts  = self.where("#{columns} like '%?%'",values).order(ord_str).limit(offset,limit)
    return contacts,total_count
  end  

  

  def assign_balance
    self.balance = self.starting_balance
  end  
 
  def rectify_contact_balance
     if starting_balance_changed?
        diff = starting_balance.to_f - starting_balance_was.to_f
        self.balance += diff
        sql = "UPDATE transactions set contact_balance = (contact_balance + (#{diff}) ) "
        sql << "where contact_id = #{self.id} "
        p sql
        ActiveRecord::Base.connection.execute(sql)      
     end
  end
    
 

  def rep_trans sdate=nil, edate=nil
     Transaction.where("contact_id = ?  ",self.id).order("on_date DESC , created_at desc")
  end  

  def rep_items sdate=nil, edate=nil
     TxnItem.where("contact_id =? ", self.id).order("id  DESC")
  end  
 
  def rep_payments sdate=nil, edate=nil 
     Payment.where("contact_id =? ", self.id).order("on_date DESC, created_at desc")
  end  

  def aggr_items
     sql =  "SELECT itm.id,itm.name,sum(txn.number) as sum_number, sum(txn.amount) as sum_amount from items itm, txn_items txn "
     sql <<  " where txn.item_id = itm.id and txn.contact_id = #{self.id} group by itm.id"
     Item.find_by_sql(sql)
  end

  def filter_aggr_items
      sql =  "SELECT itm.id,itm.name,sum(txn.number) as number, sum(txn.amount) from items itm, txn_items txn, transactions tx "
      sql <<  " where tx.id= txn.transaction_id and txn.item_id = itm.id and txn.contact_id = #{self.id} group by itm.id"
     

  end  

  def self.picklist
     c_arr = []
     self.order("name").each{|a| 
      c_arr << [a.name_subname, a.id]
     }
     return c_arr
  end  

  def self.total_starting_balance
       t_balance = 0
       self.all.each{|c|  

        t_balance = t_balance + c.starting_balance  if !c.starting_balance.blank?

       } 
       return t_balance
  end  
end
