class PaymentsController < ApplicationController


  def index
    @sort_column = params[:sort_colum] || 'on_date'
    @sort_order = params[:sort_order]  || "DESC"
    @page_size = params[:page_size] || 20
    @offset = params[:offset] || 0
    
    values = Utility.pagination_process(params,"Payments")
    @trs_text = values[1]
    total = Payment.count
    @payments = Payment.where(values[0]).order("#{@sort_column} #{@sort_order}, created_at DESC ")
  end
  
  def show
  	@payment = Payment.find(params[:id].to_i)
  end
  
  def new
  	@payment = Payment.new
    @site_name = ''
    @cont = Contact.all_conts
    @sites = Site.all
    @sb_txt = "Add Payment"
  end 	

  def create

   begin
      @p = Payment.new(params[:payment])
      params[:payment_rows].each{|key,val|

         pr = PaymentRow.new(val)
         @p.payment_rows << pr
      }

      @p.assign_amount
      @p.save!
      flash[:success] = "Payment Added Successfully"
      @payments = Payment.all
      #render js: "window.location.pathname='#{transactions_path}'"
      url = report_page_contact_path(:id => @p.contact_id)
      render js: "window.location.pathname='#{url}'"

   rescue Exception => e
     @trans = @p
     @serr = @e.to_s
     p e.to_s
     respond_to do |format|
       format.js {render layout: false}
     end       
   end 

  end	

  def edit
  	@payment = Payment.find(params[:id].to_i)
    @site_name = (@payment.site.blank? ?  "":@payment.site.name)
    @sb_txt = "Update Payment"
    @cont = Contact.all_conts
    @sites = Site.all
  end

  def update

  	@payment = Payment.find(params[:id].to_i)
    payrow_ids = []
     params[:payment_rows].each{|key,val|
      id = key.to_i
      payrow_ids << id

      if id < 1000
        pr = PaymentRow.new(val)
        pr.created_by = @auser.id
        pr.save!
        @payment.payment_rows << pr
      else
        val[:updated_by] = @auser.id
        old_pr = PaymentRow.find(key)
        old_pr.update_attributes(val)
      end 

      } unless  params[:payment_rows].blank?

      @payment.payment_rows.each{|p|

       p.destroy if !payrow_ids.include?(p.id)
      }

    @payment.assign_amount
    @payment.save!
    @payment.update_attributes(params[:payment])
    flash[:notice] = "Payment #{@payment.id} has been updated "
    @trs = Payment.all
    render js: "window.location.pathname='#{payments_path}'"
    
  end

  def remove
  	@payment = Payment.find(params[:id].to_i)
  	@payment.destroy
    redirect_to :action =>'index'
  end


  def add_payment_row
    @row_no = params[:row_no].to_i + 1
    @payment_row = PaymentRow.new(:transaction_id => params[:transaction_id])
    respond_to do |format|
     format.js {render layout: false}
    end
  end  

  def pagination
    @sort_column = params[:sort_colum] || 'on_date'
    @sort_order = params[:sort_order]  || "DESC"
    @page_size = params[:page_size] || 20
    @offset = params[:offset] || 0
    
    values  = Utility.pagination_process(params,"Payments")

     @trs_text = values[1]
    total = Payment.count
    @payments = Payment.where(values[0]).order("#{@sort_column} #{@sort_order}, created_at DESC ")
    respond_to do |format|
      format.js {render layout: false}
    end 
  end  


  def jx_new
  end
  
  def jx_save
    p params
     @payment = Payment.new(params[:payment])
      params[:payment_rows].each{|key,val|

         pr = PaymentRow.new(val)
         @payment.payment_rows << pr
      }
     @row_ct = params[:row_ct].to_i
     @payment.assign_amount
     sleep 5
     @payment.save!
      flash[:success] = "Pyment Added Successfully"
      respond_to do |format|
      format.js {render layout: false}
    end 
  end  

  def jx_row
  end  

  def async_payment_form
    @payment = Payment.new
    @site_name = ''
    @cont = Contact.all_conts
    @sites = Site.all
    @sb_txt = "Add Payment"
  end  

  def clear_form
      respond_to do |format|
      format.js {render layout: false}
    end 
  end  
	
end	