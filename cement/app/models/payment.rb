class  Payment < Transaction
   
  default_scope { where(trans_type: 'payment') }
  validate :all_validation
  audited :allow_mass_assignment => true
  belongs_to :contact
  has_many :payment_rows, :foreign_key => :transaction_id
   
  before_create  :calculate_contact_balance, :add_trans_type
  before_update  :rectify_amount
  after_create  :update_balance_changes
  after_update  :update_balance_changes
  after_destroy :destroy_balance_changes
  include BaseUtils
 

  def all_validation
     errors.add(:date, "Date can not be blank") if on_date.blank?
     errors.add(:contact, "Contact can not be blank") if contact.blank?
     errors.add(:payment_amount, "Enter valid payment amount") if payment_amount.blank? || payment_amount.to_i == 0 
  end

  def assign_amount
    a = 0
    self.payment_rows.each{|p|
      a += p.amount
    }
    self.payment_amount = a 
  end  
  
  def is_number?
    self.to_f == self
  end

  def tofrom_contact
  	str = ""
  	str = ( (self.recieved == 1)? " from "+contact.name_subname : " to "+contact.name_subname) if !contact.blank?
    return str
  end	

   
  def name_subname
  	return (contact.blank? ? "":contact.name_subname)
  end	


  def add_trans_type
    self.trans_type = 'payment'
  end  

  def payment_types
    self.payment_rows.collect{|p| p.pay_type}
  end
    
  class << self

    def by_contact ids, sdate=nil, edate=nil
    end  

    def by_date sdate=nil, edate=nil
    end     

  end  


end	