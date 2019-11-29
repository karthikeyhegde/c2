#!/usr/bin/env ruby
require File.expand_path( '../../config/boot',__FILE__)
require  File.expand_path( '../../config/environment',__FILE__)


require 'csv'

filename = "changed_records_"+Time.now.to_s.split(' ').join('_')
Rails.env = "production"

ct = []
cid = []
tid = []



Contact.all.each{|c|

     trans = Transaction.where("contact_id = ?",c.id).order("on_date,created_at")
     cbalance = 0
     #cbalance =    c.starting_balance.nil? ? 0: c.starting_balance

     trans.each{|t|
      

       t.buyback == 1? txn_amount = (t.amount * -1) : txn_amount = t.amount
       t.recieved == 0? txn_payment = (t.payment_amount * -1) : txn_payment = t.payment_amount.to_f
       abc  = cbalance

       cbalance = cbalance + txn_amount - txn_payment
   

       if ( cbalance  !=  t.contact_balance.to_f  )
       	
      # 	 p " ----- abc #{abc}"
         puts  " #{c.name} -  Sbal - #{c.starting_balance.to_s} - #{t.id} - #{txn_amount - txn_payment} - runningCbalance #{cbalance} - t-c-balance #{t.contact_balance.to_f}"

       	 ct << c.name if !ct.include?(c.name)
       	 cid << c.id   if !cid.include?(c.id)
       	 tid << t.id
       end
     }

     



}





p ct.size
p ct
str = cid.join(",")
str = str
st = str[0..(str.length - 2)]
p st


 CSV.open(filename,'wb') do |csv|
  csv << ['Transaction ID','Contact Id','Transaction amount','OLD Contact Balance', 'New Balance']
   cid.each{|c|

   trans1 = Transaction.where("contact_id =  ? ",c).order("contact_id,on_date,created_at")
   cbalance = 0
   trans1.each{ |a|

   


   a.buyback == 1? txn_amount = (a.amount * -1) : txn_amount = a.amount
   a.recieved == 0? txn_payment = (a.payment_amount * -1) : txn_payment = a.payment_amount.to_f
   cbalance = cbalance + txn_amount - txn_payment
#   puts '*********************************************'	if tid.include?(a.id)
   puts "********  #{a.contact.name}  ---- #{a.id} ------- #{a.amount} #{a.payment_amount} ------  #{a.contact_balance} ---- #{cbalance}"
#   puts '******'	if tid.include?(a.id)

   csv << [a.id,a.contact_id,(txn_amount - txn_payment),a.contact_balance,cbalance]

   a.contact_balance = cbalance 
   a.save!
  }

 }
 end


