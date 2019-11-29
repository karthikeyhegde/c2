class Utility

	def self.rep_aggrigation
		sql =      " select sum(if(txn.buyback = 1, txn.amount * -1, txn.amount)) as t_amount, "
        sql <<     " sum(if(txn.buyback = 1, txn.hamaali * -1, txn.hamaali)) as t_hamaali, "
        sql <<     " sum(if(txn.buyback = 1, txn.vehicle_charges * -1, txn.vehicle_charges)) as t_vehicle_charges, "
        sql <<     " sum(if(txn.buyback = 1, txn.other_charges_amount * -1, txn.other_charges_amount)) as t_other_charges_amount,"
        sql <<     " sum(if(txn.recieved != 1, txn.payment_amount * -1, txn.payment_amount)) as t_payment_amount, "
        sql <<     " sum(if(txn.buyback = 1, txn.discount * -1, txn.discount)) as t_discount "
        sql <<     " from transactions txn "
        agr_transaction = Transaction.find_by_sql(sql)
        return agr_transaction
	end	

     


    def self.indian_number(number) 
      if number 
        string = number.to_s.split('.')
        number = string[0].gsub(/(\d+)(\d{3})$/){

          p = $2;"#{$1.reverse.gsub(/(\d{2})/,'\1,').reverse},#{p}"
        } 
        number = number.gsub(/^,/, '') + '.' + string[1] if string[1] 
        # remove leading comma 
        number = number[1..-1] if number[0] == 44 or number[0] == ','
      end 
      "#{number}" 
    end

    def self.mysql_date dates
      da =  dates.to_s.split('-')
      return da[2]+'-'+da[1]+'-'+da[0]
    end 


   
 def self.excel_export 
  id = params[:id]
   from_date = ( params[:from_date].blank? ?  '2000-01-01':params[:from_date] )
   to_date =  ( params[:to_date].blank? ? '2100-01-01' : params[:to_date] )
   f_date = DateTime.parse(from_date).strftime('%Y-%m-%d %H:%M')
   t_date = DateTime.parse(to_date).strftime('%Y-%m-%d %H:%M')

   @contact = Contact.find(id)
   @transactions = Transaction.where('contact_id = ?  and on_date between ? and ?',id,f_date,t_date).order('on_date,created_at')
 
   
    p = Axlsx::Package.new
    p.workbook.add_worksheet(:name => "Transactions") do |wb|
     # define your regular styles
      styles = wb.styles
      title = styles.add_style(:sz => 14, :b => true,:bg_color => '00FFFF')

      default = styles.add_style(:border => Axlsx::STYLE_THIN_BORDER)
      money = styles.add_style(:format_code => '##,##,##0.##', 
                           :border => Axlsx::STYLE_THIN_BORDER)
      percent = styles.add_style(:num_fmt => Axlsx::NUM_FMT_PERCENT,   
                             :border => Axlsx::STYLE_THIN_BORDER)

      wb.add_row  ['Contact:',@contact.name_subname]
      report_txt = ''
      if params[:from_date].blank? and params[:to_date].blank?
        report_txt += 'Report of all transactions.'
       else  
        report_txt += 'Transactions -'
        if !params[:from_date].blank? 
             report_txt += 'From '+params[:from_date] 
        end
         if !params[:to_date].blank? 
            report_txt += 'up to '+params[:to_date] 
        end
             
      end

      wb.add_row  [report_txt]
      wb.add_row ['Current Account Balance', @contact.balance]
      wb.add_row ['']
      count = 1
      c = 0      
      @transactions.each{|t|
        s = t.buyback == 1? '(Vaapas)':''
        wb.add_row [ 'Trans# '+count.to_s+' '+s, 'Date : '+ t.on_date.to_s, '', 'Site',t.site_name], :style => title
        wb.add_row ['']
        if t.trans_type == 'payment'
          wb.add_row [ t.tofrom + ' '+t.payment_type+' Payment:', 'Rs '+t.payment_amount_s]
          wb.add_row ['Account Balanace:', 'Rs '+t.contact_balance.to_s]
          wb.add_row ['Payment Info:', t.payment_note] ,:widths => [:ignore,:ignore,50]
          wb.add_row ['Note:', t.descri] ,:widths => [:ignore,:ignore,50]
        else  
          wb.add_row ['Item#', 'Item','Description','Price','Quantity','Amount'], :b =>true
          c = 1
          t.txn_items.each{|ti|
           wb.add_row [ c.to_s, ti.item.name,ti.item_descri,ti.price.to_s,ti.number.to_s,ti.amount.to_s] ,:widths => [:ignore,:ignore,30,30,:auto,:auto,:auto]
           c += 1
          }
          c += 1
        wb.add_row [c.to_s,'Vehicle Charges','','','',t.vehicle_charges]
        wb.add_row [(c+1).to_s,'Hamaali','','','',t.hamaali]
        wb.add_row ['','','','','Total Amount',t.amount.to_s]
        wb.add_row ['','','','', t.tofrom + ' '+t.payment_type+' Payment:', 'Rs '+t.payment_amount_s]
        wb.add_row ['','','','', 'Account Balanace:', 'Rs '+t.contact_balance.to_s]
        wb.add_row [ 'Payment Info:', t.payment_note],:widths => [:ignore,:ignore,50]
        wb.add_row ['Note:', t.descri],:widths => [:ignore,:ignore,50]
        wb.add_row ['']

        end  
        count += 1
      }

      time = DateTime.now.to_s.sub(':','')
      #p.serialize @contact.name_subname_underscore+'_transactions_'+time+'.xlsx'
      send_data p.to_stream.read, type: "application/xlsx", filename: @contact.name_subname_underscore+'_transactions_'+time+'.xlsx'
    end


 end 


    
end	