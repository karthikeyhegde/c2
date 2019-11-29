class Analytic 
  # attr_accessible :title, :body


  def self.get_paybal
  end
  	
  def self.payment_and_balance *args

  	  ord_str = args[0] || " balance desc"  
  	  user = args[1]  || 'test_user'

  	  str =  " select c.name,c.balance, c.id, c.contact_number, "
      str << "(select payment_amount from transactions where contact_id = c.id and payment_amount != 0 and payment_amount is not null order by on_date desc limit 1 )  last_paymnet_amount, "
      str << "(select on_date  from transactions where contact_id = c.id AND payment_amount != 0 and payment_amount is not null order by on_date desc limit 1 ) as last_payment_date, "
      str << "(select amount from transactions t where contact_id = c.id and (select count(*) from txn_items where transaction_id = t.id) > 0 "
      str << "order by on_date desc limit 1 ) as last_txn_amount, "
      str << "(select on_date from transactions t where contact_id = c.id and (select count(*) from txn_items where transaction_id = t.id) > 0 "

      str << "order by on_date desc limit 1 ) as last_txn_date  "
      str << "from contacts c where balance < 0 OR balance > 0 "
  
      con =  ActiveRecord::Base.connection

      con.execute("DROP table if exists paybal_#{user}") 
      con.execute(" create table paybal_#{user}  (#{str})")

     a = Analytic.get_baldetails
     return a

  end

  def self.total_balance
         sql = "SELECT SUM(IF(balance > 0 , balance , 0)) as balance, SUM(IF(balance < 0 , balance , 0)) as payment from contacts  where balance != 0  "
         con =  ActiveRecord::Base.connection
         res = con.execute(sql)
         bal = 0
         pay  = 0
          res.each{|r|
             bal = r[0].to_i
             pay = r[1].to_i
          }
         return bal,pay

   end   


   def self.get_baldetails ord = nil

    
      ord_str = ord || '((datediff(curdate(),last_payment_date) * balance) ) DESC'   
      user = 'test_user'
      con =  ActiveRecord::Base.connection
      res =  con.execute("SELECT *, if(last_payment_date is null, IF (last_txn_date is NULL,(DATEDIFF(curdate(),'2015-03-31')),(DATEDIFF(curdate(),last_txn_date))),DATEDIFF(curdate(),last_payment_date) ) as gone_days from paybal_#{user}  order by #{ord_str}")      
      arr = Analytic.mysql_to_array res
      return arr

   end 

   def self.trend_sal_bln tmline = nil  
        tmline ||= "Monthly" 
        tm_val_str = Analytic.time_grouping tmline
        start_bal = Contact.total_starting_balance
         con =  ActiveRecord::Base.connection

         con.execute(" set @smnt = #{start_bal}, @pmnt = 0")

  
        sql = "  select t.payment,t.amount, (@pmnt := @pmnt+t.payment) as running_payment,"
        sql << " (@smnt := @smnt + t.amount) as running_amount,  ((@smnt- @pmnt)) as running_balance, t.tl_value "
        sql <<  " from ( select sum(if(tx.recieved != 1, tx.payment_amount * -1, tx.payment_amount)) as payment, "
        sql << "  sum(if(tx.buyback = 1, tx.amount * -1, tx.amount)) as amount, #{tm_val_str}  from transactions tx group by tl_value) t"
      p "bal trend"
       p sql
        arr_res = Analytic.mysql_to_array con.execute(sql)
        return arr_res

   end 

   def self.time_grouping tv

    case tv

        when "Weekly"
          select = " yearweek(tx.on_date) as tl_value"
      
        when "Daily"
          select = " tx.on_date  as tl_value"
        when "Quaterly"

          select =  " CASE WHEN MONTH(tx.on_date) BETWEEN 1 AND 3 THEN CONCAT(YEAR(tx.on_date),'Q1') "
          select << " WHEN MONTH(tx.on_date) BETWEEN  4 AND 6 THEN  CONCAT(YEAR(tx.on_date),'Q2')  WHEN MONTH(tx.on_date) BETWEEN 7 AND 9 THEN  CONCAT(YEAR(tx.on_date),'Q3') "
          select << " WHEN MONTH(tx.on_date) BETWEEN 10 AND 12 THEN CONCAT(YEAR(tx.on_date),'Q4') END AS tl_value "
 
        when  "Yearly"
          select = " YEAR(tx.on_date) as tl_value" 
        else
              # Default Calculation  Monthly by Year
          select  =  " CONCAT(YEAR(tx.on_date),LPAD(MONTH(tx.on_date), 2, '0')) as tl_value "
      end 

        

    end   


    def self.mysql_to_array mysql_res
           
      arr = []
      mysql_res.each{|r|
         k = []
         r.each{|a| k << a }
         arr << k
      }
       return arr
    end  
   

   def self.item_sales params = nil


        itemsales = Report.new
        itemsales.timeline_value = 'Monthly'
        itemsales.number_of  = '6'
        itemsales.dynamic_date_value = "Months"
  
        itemsales.r_value = User.current_user.id.to_s+"_itemsales"
        itemsales.grouping_ord = "Item,Timeline"

        itemsales.first_query_table
        itemsales.results

       sql =  " select itm.id,itm.name,sum(if(txn.buyback = 1, txnitm.amount * -1, txnitm.amount)) as t_item_sum,"
       sql << " sum(if(txn.buyback = 1, txnitm.number * -1, number)) as t_item_no  "
       sql << " from txn_items txnitm, transactions txn, items itm "  
       sql << " where txnitm.transaction_id = txn.id and txnitm.item_id =itm.id "
       sql << " group by txnitm.item_id  "

       f_sql =  "  SELECT titem.id,titem.name,titem.t_item_sum,titem.t_item_no, "
       f_sql << "  rp.* from  report_temp_2_#{itemsales.r_value} rp   right Join  (#{sql}) as titem "
       f_sql << "  on titem.id = rp.item_id order by titem.name "

     con =  ActiveRecord::Base.connection
     res = con.execute(f_sql)
     re_arr = Analytic.mysql_to_array res
     n_arr = []
    re_arr.each{|ra|

      ra.delete_at(4)
      ra.delete_at(4)
      

 
     n_arr << ra

   }


     return re_arr, itemsales

   end 

   def self.item_sales_filter rep
     rep.r_value = User.current_user.id.to_s+"_itemsales"
     rep.grouping_ord = "Item,"+rep.grouping_ord
     rep.first_query_table
     rep.results
     re_arr = Analytic.itemsales_data rep.r_value
      p "KILLL"
      p rep.headers
     return re_arr,rep

   end 


   def self.itemsales_data r_value
     f_sql = " SELECT tsum.item_id,tsum.item_name,tsum.total_sum,tsum.total_num,t.*  from "
     f_sql << " (SELECT t1.item_id,t1.item_name,SUM(t1.sum_amount) as total_sum,SUM(t1.sum_number) total_num FROM report_temp_#{r_value} t1 group by item_id) as tsum ,"
     f_sql << "  report_temp_2_#{r_value} as t where tsum.item_id = t.item_id order by tsum.item_name "
  
     con =  ActiveRecord::Base.connection
     res = con.execute(f_sql)
     re_arr = Analytic.mysql_to_array res
     re_arr.each{|ra|
        ra.delete_at(4)
        ra.delete_at(4)
     }

     return re_arr
   end 

  def self.block1_report rep 

     rep.timeline_value = "Yearly"
     rep.r_value = User.current_user.id.to_s+"_fb_1"
     rep.grouping_ord = "Item,Contact"
     rep.first_query_table
    
     sql =  " select tb.item_id,tb.item_name,sum(tb.sum_amount) t_item_sum,"
     sql << " sum(tb.sum_number) as t_item_no  "
     sql << " from  report_temp_#{rep.r_value}  as tb"  
     sql << " group by tb.item_name order by t_item_sum desc"

     con =  ActiveRecord::Base.connection
     items = con.execute(sql)
   
     sql =  " select tb.contact_id,tb.contact_name,sum(tb.sum_amount) t_item_sum,"
     sql << " sum(tb.sum_number) as t_item_no  "
     sql << " from  report_temp_#{rep.r_value}  as tb"  
     sql << " group by tb.contact_id order by t_item_sum desc"
     customers = con.execute(sql)

     top_items = Analytic.mysql_to_array items
     top_customers = Analytic.mysql_to_array customers


     total_number = 0
     total_sum  = 0

      top_items.each{|i|
        total_sum += i[2]
        total_number += i[3]
      }
     return top_items,top_customers, rep,total_number,total_sum
  end 
  

  

   def self.get_customer_sales(limit = nil)
    
   # sql =  " select txn.contact_id,c.name, sum(if(txn.buyback = 1, txn.amount * -1, txn.amount)) as t_sum "
   # sql << " from transactions txn, contacts c where c.id = txn.contact_id  group by contact_id order by t_sum DESC"
   # sql << " limit #{limit} " if !limit.nil? and limit.to_i > 0

    sql = "select txn.contact_id,c.name, sum(if(txn.buyback = 1, txi.amount * -1, txi.amount)) as t_sum"
    sql <<  " from transactions txn , txn_items txi , contacts c  where c.id = txn.contact_id  and txi.transaction_id = txn.id "
    
    sql << " group by contact_id order by t_sum DESC "
    sql << " limit #{limit} " if !limit.nil? and limit.to_i > 0

    con =  ActiveRecord::Base.connection
    res = con.execute(sql)
    re_arr = Analytic.mysql_to_array res
    return re_arr

   end 

   def self.trend_sales rep
        tmline ||= "Monthly" 
        tm_val_str = Analytic.time_grouping tmline
        rep.grouping_ord = "Timeline"
        cndn_qry =  rep.conditional_query


         con =  ActiveRecord::Base.connection

         con.execute(" set @smnt = 0, @pmnt = 0")

  
        sql = "  select t.sum_amount, (@smnt := @smnt + t.sum_amount) as running_amount,  t.#{rep.timeline_group_str} "
        sql << " FROM (#{cndn_qry}) t "

        arr_res = Analytic.mysql_to_array con.execute(sql)
        column_names = arr_res.collect{|a| a[2] }
        rep.header_column = "Timeline"
        header = rep.table_headers column_names

        return header, arr_res
    
   end 

   



   

end
