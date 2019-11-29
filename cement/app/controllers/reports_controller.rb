class ReportsController < ApplicationController

	 def index
	 	    agr_transaction = Utility.rep_aggrigation
        @aggrigate_trans = agr_transaction.first
        @other_charges = @aggrigate_trans["t_hamaali"] + @aggrigate_trans["t_vehicle_charges"].to_d + @aggrigate_trans["t_other_charges_amount"]
        @total_sales = @aggrigate_trans["t_amount"] - @other_charges
        @contact_balance = Contact.sum :balance
        @r_value =  rand(36**8).to_s(36)
    end 	



    def report_query
        Report.query_construction        
    end    

    def saved_message
       
    end  

    def generate
      begin
        @report = Report.create_with_params params[:report]
       if params[:commit] == 'Save'
         
         @report.save!
         redirect_to :saved_message, :params =>{:id => @report.id}
       end  
       #Report.query_construction params[:report]
       @report = Report.start_query @report
       respond_to do |format|
         format.js {render layout: false}
       end 
      rescue Exception => e
        p e.to_s
       p e.backtrace
    
      end  
    end 

end