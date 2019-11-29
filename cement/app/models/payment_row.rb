 class PaymentRow < ActiveRecord::Base
  
  include BaseUtils
  audited :allow_mass_assignment => true
  belongs_to :transaction
  belongs_to :payment, :foreign_key => :transaction_id
  

end