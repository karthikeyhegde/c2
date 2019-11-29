class Report < ActiveRecord::Base
  

  attr_accessor :timeline_select, :gord_arr, :gord_column_names, :headers
  attr_accessor :res_bunch, :group_order, :time_line_value, :r_value, :column_names, :sub_headers
  attr_accessor :timeline_group_str, :show_from_date, :show_to_date,:header_column

  audited :allow_mass_assignment => true
  include BaseUtils

 
  def initilaize
    @gord_arr = []
    @gord_column_names = []
    @column_names  = []
    @headers  = []
    @timeline_group_str
    @header_column
  end 

   class Array
     def in_str
       self.map(&:inspect).join(',')
     end
   end


   def self.create_with_params params
    p "BBBB"
        report = Report.new(params)
        report.item_ids = params["item_ids"].compact.reject(&:blank?).join(",") 
        report.contact_ids = params["contact_ids"].compact.reject(&:blank?).join(",")
        p "GGGG"
        report.site_ids = params["site_ids"].compact.reject(&:blank?).join(",")    
        report.grouping_ord = params["group_order"].compact.reject(&:blank?).join(",") unless  params["group_order"].nil?
        report.timeline_value = params["time_line_value"]
p "KI"
        return report

   end 


   def self.start_query report


     report.first_query_table
     report.results

     return report
   end 

  

  def Report.in_ids arr 
     arr.map(&:inspect).join(',')
  end  



  def  first_query_table    
    run_first_table_query(conditional_query)   
  end	


  def date_conditions
     date_str = ''
    if !dynamic_date_value.blank?
        date_str =  dynamic_dates(number_of,dynamic_date_value)
      else
       fdate =  from_date.blank? ? '2000-01-01' : from_date.to_s(:db) 
       tdate =  to_date.blank? ? '2100-01-01' : to_date.to_s(:db) 
       @show_from_date = fdate
       @show_to_date = tdate
       date_str  = " and on_date  between '"+fdate+"' and '"+tdate+"'"  
      end   
      return date_str
  end  


  def filter_conditions
      where_in_condition = ""
      where_in_condition << " and it.id in ( #{item_ids}) " if !item_ids.blank?
      where_in_condition << " and tx.contact_id in (#{contact_ids})" if !contact_ids.blank?
      where_in_condition << " and tx.site_id in (#{site_ids})" if !site_ids.blank?
      return where_in_condition
  end  

  def from_and_where_conditions
      itm_arr = item_ids
      ct_arr = contact_ids
      st_arr = site_ids
 
      from_str = " from txn_items ti, transactions tx "
      where_str = " ti.transaction_id = tx.id "

      if ( !ct_arr.blank? ||  grouping_ord.include?("Contact"))
        from_str << " , contacts c "
        where_str << " and tx.contact_id = c.id "
      end

      if ( !itm_arr.blank? || grouping_ord.include?("Item") )
        
        from_str << " , items it "
        where_str << " and ti.item_id = it.id "
      end

      if ( !st_arr.blank?  || grouping_ord.include?("Site") )
        from_str << " , sites st " 
        where_str << " and tx.site_id = st.id "
      end

      return from_str, where_str + filter_conditions + date_conditions
  end  


  def conditional_query

      date_str = date_conditions
      timeline_select_str , @timeline_group_str = get_timeline_values
      groupby_str = ""
      i = 0
       
      grouping_ord.split(",").each{|ord|

           groupby_str << " , "  if i != 0 
           groupby_str << " it.name "  if ord == "Item"
           groupby_str << " st.name "  if ord == "Site"
           groupby_str << " c.name "   if ord == "Contact"
           groupby_str <<  @timeline_group_str if ord == "Timeline"
           i = 1
      }

      from_str, where_condn = from_and_where_conditions
      query_str = ""
      query_str = (get_select_query) + timeline_select_str
      query_str << from_str + " WHERE " + where_condn
      query_str << " group by "+groupby_str
      p "k"
      p query_str

      return query_str

  end  

  def run_first_table_query query_str
      q_str = " create table report_temp_#{r_value}   ( "+query_str+")"
      con =  ActiveRecord::Base.connection
      con.execute(" DROP TABLE IF exists  report_temp_#{r_value} ")
      con.execute(q_str)
  end  



  def coulmn_name_logic

     gord = grouping_ord.spilt(",")[0..1]
     g1 = gord[0]
     g2 = gord[1]
     gord.size > 2? g3 = gord[2] :g3 = nil  

     gord_arr = grouping_ord.split(",")

     gord_selct = ""

     gord_arr.each{|ga|

       case ga
       when "Item"
           gord_column_names << "item_id"
           gord_selct << " it.name as item_name, it.id as item_id, "
       when "Contact"
           gord_column_names << " contact_id "
           gord_selct << " c.name  contact_name, c.id as contact_id,  "
       when "Site"     
           gord_arr << " site_id "
           gord_column_names << " st.name as site_name, st.id as site_id,  " 
       end

    }
         return gord_select

  end  
  

 def get_select_query 

    str = ' select '
    str << " it.name as item_name, it.id as item_id, " if grouping_ord.split(",").include?("Item")
    str << " c.name  as contact_name, c.id as contact_id,  "  if grouping_ord.split(",").include?("Contact")
    str << " st.name as site_name, st.id as site_id,  "  if grouping_ord.split(",").include?("Site")
    str << " sum( if(tx.buyback = 1, -1 * ti.amount, ti.amount)) as sum_amount, "
    str << " sum( if(tx.buyback = 1, -1 * ti.number, ti.number)) as sum_number "
 end 



  def get_timeline_values
     return  "","" if !grouping_ord.split(",").include?("Timeline")
     group_by_str = ""
     select = ""

      case timeline_value
        when  "Monthly"
          select  =  " CONCAT(YEAR(tx.on_date),LPAD(MONTH(tx.on_date),2, '0') ) as year_and_month "
          group_by_str = "year_and_month"
          

        when "Weekly"
          select = " yearweek(tx.on_date) as year_week"
          group_by_str = " year_week "
      
        when "Daily"
          select = " tx.on_date "
          group_by_str = " tx.on_date "
          @timeline_select = "on_date"

        when "Quaterly"

          select =  " CASE WHEN MONTH(tx.on_date) BETWEEN 1 AND 3 THEN CONCAT(YEAR(tx.on_date),'Q1') "
          select << " WHEN MONTH(tx.on_date) BETWEEN  4 AND 6 THEN  CONCAT(YEAR(tx.on_date),'Q2')  WHEN MONTH(tx.on_date) BETWEEN 7 AND 9 THEN  CONCAT(YEAR(tx.on_date),'Q3') "
          select << " WHEN MONTH(tx.on_date) BETWEEN 10 AND 12 THEN CONCAT(YEAR(tx.on_date),'Q4') END AS quarter "

          group_by_str = " quarter "
        
        when  "Yearly"
         select = " YEAR(tx.on_date) date_year "
         group_by_str = " date_year "
      end 

      @timeline_select = group_by_str if @timeline_select.blank?
      select = " , "+select if !select.blank?

      p " TIMELINE SELECT --- 2"
      p  timeline_select
      @timelne_group_str = group_by_str
      timelne_group_str = group_by_str



      return  select,group_by_str 
  end
  

  def timline_string
  end  

    

 def dynamic_dates(no_of,date_value)
 	
    number = no_of.to_i
     case date_value
     when "Days"
       from_date = number.days.ago
     when "Weeks"
       from_date =  (DateTime.now.to_date - number.week).at_beginning_of_week - 1.day
     when "Months"
       from_date = (DateTime.now.to_date - number.months).at_beginning_of_month    
     when "Year"	
       from_date = (DateTime.now.to_date - number.years).at_beginning_of_year
     else
       from_date = 30.days.ago
     end
     to_date = DateTime.now.to_date.to_s(:db)
     from_date = from_date.to_s(:db)
     @show_from_date = from_date
     @show_to_date = to_date
     date_str = " and on_date  between '"+from_date+"' and '"+to_date+"'"

  end 


  def table_headers header_arr

      con =  ActiveRecord::Base.connection
    
      headers = []
      sub_headers = []
      p "HERE"
      p @header_column

      case @header_column

      when  "Item", "Site" ,"Contact"

    
         res = con.execute  "Select distinct( #{@header_column.downcase}_name) as c_name, #{@header_column.downcase}_id as c_id from  report_temp_#{r_value}  order by #{@header_column.downcase}_name "

         res.each{|a|
        
          headers  << [a[0],a[1]]
         }

         p "in ITEM"
         p headers

     
      when 'Timeline'

         case timeline_value
          when  "Monthly"
            
            month_arr = [ 'NULL','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
            header_arr.each{|h| 
              y_val = h[0..3]
              m_val = h[4..5]
              m_name = month_arr[m_val.to_i]
              headers <<  [m_name , y_val]
            }

          when "Weekly"
            header_arr.each{|h| 
              y_val = h.to_s[0..3]
              w_val = h.to_s[4..5]
              
              w_start =  Date.commercial(y_val.to_i,w_val.to_i,1).to_s
              w_end = Date.commercial(y_val.to_i,w_val.to_i,7).to_s
              headers <<   [" Mon, "+w_start , " To Sun, "+w_end]
            }
          when "Quaterly"

            header_arr.each{|h|
                case h[4..5]
                  when "Q1"
                     headers <<  ["Q1 "+h[0..3] , "Jan Feb Mar "]
                  when "Q2"
                    headers << ["Q2 "+h[0..3], "Apr May Jun "]
                  when "Q3"
                    headers <<  ["Q3 "+h[0..3], "Jul Aug Sep "]
                  when "Q4"
                    headers << ["Q4 "+h[0..3], "Oct Nov Dec "]
                  end    
            }
           when "Daily"
             header_arr.each{|h|
              hr =  h.split('')
              headers << [" #{h[0]} #{h[1]}","#{h[2]} #{h[3]}"]
             }
                 
           when "Yearly"
            header_arr.each{|h|
              headers << [h,'']
             }

          end     
      end 
         
      p "Headers --"
      p headers
      return headers
  end  

  def second_query

     gord = grouping_ord.split(",")[0..1]
     g1 = gord[0]
     g2 = gord[1]
     gord.size > 2? g3 = gord[2] :g3 = nil  

     gord_arr = grouping_ord.split(",")

     con =  ActiveRecord::Base.connection
     
     sql_res = []
     select_cn = []

      gord.each{|g|
        cn =''
        ord = ''
        case g
          when "Item"
            cn = 'item_id'
            ord = "item_name"
          when 'Contact'
            cn = 'contact_id'
            ord = 'contact_name'
          when 'Site'
            cn = 'site_id'
            ord = "site_name"
          when 'Timeline'
            cn = @timeline_select
            ord = "col_name"
          end        

          select_cn << cn

          sql_res << con.execute(" SELECT DISTINCT(#{cn}) as col_name from  report_temp_#{r_value}  order by #{ord}") 
          
     
      }
     
      
      column_names = []
      sql_res.each{|c|
         abc  =[]

         c.each{|a| abc << a }

          column_names <<  abc.flatten(1)   
       }

      p column_names


    @header_column = gord[1]

=begin
    if ( false and column_names.size > 1 and column_names[1].size > column_names[0].size )
   
       temp_column = column_names[0]
       column_names[0] = column_names[1]
       column_names[1] = temp_column
       tmp = select_cn[0]
       select_cn[0] = select_cn[1]
       select_cn[1]  = tmp
       @header_column = gord[0]
   end
=end
   
   @headers =  table_headers column_names[1]

   p "HEDWRS 22"
   p @headers
   @gord_column_names = column_names

   f_cn_name = select_cn[0].split('_')[0]+"_name"  if select_cn[0].include?('_id')
   select_cndn = " SELECT  #{select_cn[0]} "
   select_cndn << ", "+f_cn_name if !f_cn_name.blank?


   column_names[1].each{|cn| 

     cn = "#{cn}".gsub('-','')  if timeline_value == "Daily"
     select_cndn << ", SUM( IF(#{select_cn[1]} =  '#{cn}', sum_amount,0)) as sum_#{cn} " 
     select_cndn << " , SUM( IF(#{select_cn[1]} =  '#{cn}', sum_number,0)) as no_#{cn} "

   }


     select_cndn <<  " from  report_temp_#{r_value}  group by #{select_cn[0]} "

     select_cndn << " order by #{f_cn_name} " if !f_cn_name.blank?
     

      return select_cndn
      
   end 


  def results
      q_str = " create table report_temp_2_#{r_value}   ( "+self.second_query+")"
      con =  ActiveRecord::Base.connection
      con.execute(" DROP TABLE IF exists  report_temp_2_#{r_value} ")
      con.execute(q_str)
      @res_bunch  = con.execute("select * from  report_temp_2_#{r_value}")

  end  

  

  def contact_filter
    
      sql_str = "SELECT tx.* FROM transactions tx "
      fm_c = ''
      where_in_condition = " where 1=1 "
      if !item_ids.blank?
       where_in_condition << " and tx.id = tx_itm.transaction_id and tx_itm.item_id in ( #{item_ids}) " 
       fm_c = ' , txn_items tx_itm '
      end 
      where_in_condition << " and tx.contact_id in (#{contact_ids})" if !contact_ids.blank?
      where_in_condition << " and tx.site_id in (#{site_ids})" if !site_ids.blank?

      sql_str += fm_c+where_in_condition+ date_conditions+' order by  on_date desc,tx.created_at desc'

      return Transaction.find_by_sql(sql_str)

  end  
  
  def item_contact_filter

      sql_str = "SELECT tx_itm.*,tx.on_date FROM transactions tx , txn_items tx_itm , items itm "
      fm_c = ''
      where_in_condition = " where tx.id = tx_itm.transaction_id  and itm.id = tx_itm.item_id "
      if !item_ids.blank?
       where_in_condition << " and tx_itm.item_id in ( #{item_ids}) " 
      end 

      where_in_condition << " and tx.contact_id in (#{contact_ids})" if !contact_ids.blank?
      where_in_condition << " and tx.site_id in (#{site_ids})" if !site_ids.blank?

      sql_str += fm_c+where_in_condition+ date_conditions+' order by  on_date desc, id ASC'
      p "SQL STR"
      p sql_str

      grouping_sql =" SELECT itm.id,itm.name, SUM(number) as sum_number, SUM(tx_itm.amount) as sum_amount FROM transactions tx , txn_items tx_itm, items itm  "
      grouping_sql += where_in_condition+date_conditions+" group by itm.id order by itm.name"
      p "KLKLKL"
      p  grouping_sql
      return TxnItem.find_by_sql(sql_str), Item.find_by_sql(grouping_sql)

  end  

  def payment_contact_filter
      sql_str = "SELECT tx.* FROM transactions tx "
      fm_c = ''
      where_in_condition = " where tx.trans_type = 'payment' "
      if !item_ids.blank?
       where_in_condition << " and tx.id = tx_itm.transaction_id and tx_itm.item_id in ( #{item_ids}) " 
       fm_c = ' , txn_items tx_itm '
      end 
      where_in_condition << " and tx.contact_id in (#{contact_ids})" if !contact_ids.blank?
      where_in_condition << " and tx.site_id in (#{site_ids})" if !site_ids.blank?

      sql_str += fm_c+where_in_condition+ date_conditions+' order by  on_date desc,tx.created_at desc'
      return Payment.find_by_sql(sql_str)

  end  

end
