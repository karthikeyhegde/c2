#!/usr/bin/env ruby
require File.expand_path( '../../config/boot',__FILE__)
require  File.expand_path( '../../config/environment',__FILE__)


require 'csv'

filename = "/home/arjun/2.1/cement/script/log/changed_records_"+Time.now.to_s.split(' ').join('_')
Rails.env = "production"
ct = []
cid = []
tid = []

message = []

Contact.all.each{|c|

     trans = Transaction.where("contact_id = ?",c.id).order("on_date,created_at")
     cbalance = 0
     add_break = false
     trans.each{|t|
      
       t.buyback == 1? txn_amount = (t.amount * -1) : txn_amount = t.amount
       t.recieved == 0? txn_payment = (t.payment_amount * -1) : txn_payment = t.payment_amount.to_f
       cbalance = cbalance + txn_amount - txn_payment
   

       if ( cbalance  !=  t.contact_balance.to_f  )

         message  <<  " #{c.name} -  Sbal - #{c.starting_balance.to_s} |  #{t.id} -  Total Amount : #{txn_amount - txn_payment} - RunningCbalance: #{cbalance} - TransContactbalance #{t.contact_balance.to_f} "
        p  " #{c.name} -  Sbal - #{c.starting_balance.to_s} |  #{t.id} -  Total Amount : #{txn_amount - txn_payment} - RunningCbalance: #{cbalance} - TransContactbalance #{t.contact_balance.to_f} "
         add_break = true
       	 ct << c.name if !ct.include?(c.name)
       	 cid << c.id   if !cid.include?(c.id)
       	 tid << t.id
       end
        
     }
     if add_break
         message <<"------------------------------------------------------"
         message << ''
       end 

}





p " Difference In Balance"
message << "  ===== Difference In Balance ===== "
Contact.all.each{|c|

   @transactions = Transaction.where('contact_id = ?',c.id)

    if c.starting_balance.nil?
      sb = 0
    else
      sb = c.starting_balance
    end  
    balanceamt = (Transaction.total_balance @transactions) + sb

    if c.balance != nil and !c.starting_balance.nil? and  ((c.balance - balanceamt).abs >= 1)
      ct << c.id
      p " Contact =  "+c.id.to_s+"  "+c.name
      p " Caluculated "+  balanceamt.to_s
      p " Balance  "+c.balance.to_s
      p "----------------------"
      message <<  " Contact =  "+c.id.to_s+"  "+c.name
      message <<  " Caluculated "+  balanceamt.to_s
      message <<  " Balance  "+c.balance.to_s
      message <<  "-----------------------------------------"
      ct << c.name if !ct.include?(c.name)
      cid << c.id   if !cid.include?(c.id)
    end  
}



p ct.size
p ct
str = cid.join(",")
st = str[0..(str.length - 2)]
p st
p '----- ABCD--'
p cid.size
if(cid.size > 1)
 message = [ct]+ [str] + message
 UserMailer.daily_report('alerts.karthikeya@gmail.com',message,'Cement - Balance Diffrencees').deliver 
end

 CSV.open(filename,'wb') do |csv|
  csv << ['Transaction ID','Contact Id','Transaction amount','OLD Contact Balance', 'New Balance']
   cid.each{|c|

   trans1 = Transaction.where("contact_id =  ? ",c).order("contact_id,on_date,created_at")
   cbalance = 0
   trans1.each{ |a|

   


   a.buyback == 1? txn_amount = (a.amount * -1) : txn_amount = a.amount
   a.recieved == 0? txn_payment = (a.payment_amount * -1) : txn_payment = a.payment_amount.to_f
   cbalance = cbalance + txn_amount - txn_payment
   puts '*********************************************'	if tid.include?(a.id)
   puts " #{a.contact.name}  ---- #{a.id} ------- #{a.amount}  #{a.payment_amount} ------  #{a.contact_balance} ---- #{cbalance}"
   puts '******'	if tid.include?(a.id)

  csv << [a.id,a.contact_id,(txn_amount - txn_payment),a.contact_balance,cbalance]

   a.contact_balance = cbalance 
   a.save!
  }

 }
 end

