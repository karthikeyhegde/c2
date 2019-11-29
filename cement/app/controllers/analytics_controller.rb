class AnalyticsController < ApplicationController
   layout 'analytics'
	def aggr_payments
		@paybal = Analytic.payment_and_balance 'gone_days desc , balance desc'
		@bal, @pay = Analytic.total_balance
        @balance_trend = Analytic.trend_sal_bln 'Monthly'
    end		

    

    def sort_baldtls
        ord = params[:ord]
        colname = params[:col_name].strip
        colname  = 'balance' if colname == 'Balance'
        colname =  'name' if colname == 'Name'
        colname  = 'last_payment_date' if colname == "Last Payment"
        colname = 'last_txn_date'  if colname == 'Last Trans'
        colname = 'gone_days' if colname == "#Days"
        @paybal = Analytic.get_baldetails colname+" "+ord

        respond_to do |format|
         format.js {render layout: false}
       end  
    end    



   def sales

     @its,@itemsales =  Analytic.item_sales
     @total_salesamnt = 0
     @total_salesnm = 0
     @its.each{|irs|
       @total_salesamnt += irs[2]
       @total_salesnm  += irs[3]
     }
     @report = Report.new
     @from_date = "1 Jan 2015"

     @top_customers =  Analytic.get_customer_sales(10)
     
     @rp = Report.new(:timeline_value => "Monthly", :grouping_ord => "Timeline")
     @header, @sales_trend   =  Analytic.trend_sales @rp



   end 

   def filter_block1

    
     if params[:commit] == "Show" or params[:commit] == "Save as"
       rep =  Report.create_with_params params[:report]
     elsif params[:report].blank? and !params[:id].blank? 
       rep = Report.find(params[:id])
     end 

     @its,@top_customers, @report,@total_salesnm,@total_salesamnt = Analytic.block1_report rep
     @act = 'filter_block1'
     @from_date = @report.show_from_date
     @to_date = @report.show_to_date

     if params[:commit] == "Save as"
       if !params[:id].blank?
           rp = Report.find(params[:id])
           rp.update_attributes!(params[:report])
        else
           @report.tag="analytics_block1"
           @report.save!    
       end 
     end 

     respond_to do |format|
        format.js {render layout: false}
     end 
  
   end

   
   def filter_block2
  
      @report = Report.create_with_params params[:report]
      @header,@sales_trend   =  Analytic.trend_sales @report

       if params[:commit] == "Save as"
         if !params[:id].blank?
             rp = Report.find(params[:id])
             rp.update_attributes!(params[:report])
          else
             @report.tag="analytics_block2"
             @report.save!    
         end 
       end 

       respond_to do |format|
        format.js { render layout: false }
     end  
   end


   def filter_block3
      
      @report = Report.create_with_params params[:report]
      @its,@itemsales = Analytic.item_sales_filter @report


      if params[:commit] == "Save as"
         if !params[:id].blank?
             rp = Report.find(params[:id])
             rp.update_attributes!(params[:report])
          else
             @report.tag="analytics_block3"
             @report.save!    
         end 
       end 

      respond_to do |format|
        format.js { render layout: false }
     end  
   end 

   def sort_itemsales

      cnum = params[:i].to_i 
      cindex = cnum + 1 if cnum < 2
      cindex = cnum * 2 if cnum > 1

      @its1 =  Analytic.itemsales_data User.current_user.id.to_s+"_itemsales"
      p "CI"
      p cindex
      @its1.each{|a| p a[cindex]}

      @its  = ( params[:ord] =='ASC'? @its1.sort{|a,b| a[cindex] && b[cindex] ? a[cindex] <=> b[cindex] : a[cindex] ? -1 : 1 } :  @its1.sort{|a,b|  a[cindex] && b[cindex] ? b[cindex] <=> a[cindex] : a[cindex] ? -1 : 1})

      respond_to do |format|
         format.js {render layout: false}
       end  

   end 

end

