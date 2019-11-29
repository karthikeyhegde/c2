class TransactionsController < ApplicationController
  @@available_action = ['new_sale','new_return','new_payment']
 
 def index
  @sort_column = params[:sort_colum] || 'on_date'
  @sort_order = params[:sort_order]  || "DESC"
  @page_size = params[:page_size] || 20

  no_of_weeks =  params[:no_of_weeks].blank? ? 0 : params[:no_of_weeks].to_i
  date_str = "on_date > '"+no_of_weeks.weeks.ago.strftime("%Y-%m-%d")+"' " if no_of_weeks > 1
  @trs_text = "Showing  transactions from last "+no_of_weeks.to_s+" weeks ."
  
  limit = ""
  if  no_of_weeks < 1
   date_str = " 1=1 "
   limit = "LIMIT 25"
  end  

  if !params[:from_date].blank? || !params[:to_date].blank?
    from_date = ( params[:from_date].blank? ?  '2000-01-01': DateTime.parse(params[:from_date]).strftime('%Y-%m-%d %H:%M'))
    to_date   = ( params[:to_date].blank? ? '2100-01-01' : DateTime.parse(params[:to_date]).strftime('%Y-%m-%d %H:%M') )
    date_str  = " on_date  between '"+from_date+"' and '"+to_date+"'"
    @trs_text = " Showing transactions "
    @trs_text += " from "+params[:from_date] if  !params[:from_date].blank?
    @trs_text += " up to "+params[:to_date] if  !params[:to_date].blank?
  end
  offset = params[:offset] || 0
  total = Transaction.count
  @trs = Transaction.where(date_str).order("#{@sort_column} #{@sort_order}, created_at DESC #{limit}")
  
 end

 def show
 end

 def new
   @trans = Transaction.new
   @form_method = 'post'
   render :action => params[:tx_type] if  @@available_action.include?(params[:tx_type])
 end

 def new_sale
 end
 
 def new_return
 end 

 def new_payment
 end 

 def edit
   @trans = Transaction.find(params[:id])
   @contact_name = @trans.contact.name.to_s+" "+@trans.contact.subname.to_s
   @site_name = (@trans.site.blank? ?  "":@trans.site.name)
   @form_method = 'put '
 end

 def create
  p "PARAMS"
  p params
    @trans = Transaction.new(params[:transaction])
    @trans.created_by = @auser.id
    params[:txn_items].each{ |key,val|
     item_params = val
     unless ( item_params[:item_id].blank? || item_params[:item_id].to_i == 0) && item_params[:item_descri].blank? 
      ti = TxnItem.new(item_params)
      ti.contact_id = params[:transaction][:contact_id]
      ti.amount = ti.calculate_amount
      ti.buyback_now = @trans.buyback
      @trans.txn_items << ti
     end 
    }

     contact_name = params[:txn][:contact].strip
      if !contact_name.blank? and  contact_name.length > 3
        cnt =  Contact.find(params[:transaction][:contact_id]) if !params[:transaction][:contact_id].blank?
        if cnt.blank? || cnt.name_subname != contact_name
            contact = Contact.new
            contact.name = contact_name
            contact.regular = 0
            contact.save!
            @trans.contact_id = contact.id
        end  
         
      end  

     site_param = params[:txn][:site].strip
     if !site_param.blank? and  site_param.length > 3
       site = Site.find_by_name(site_param)
       if site == nil
         site = Site.new
         site.name = site_param
         site.save!
       end 
      


       @trans.site = site
     end
   begin
      @save_success = false
      @trans.save!
      @trs = Transaction.all
      
      flash[:notice] = 'Transaction# '+@trans.id.to_s+' added Successfully !'
      flash.keep(:notice)

      if params[:commit] == 'Save and +New'
     
            #format.js {render 'save_and_ad_new', layout: false}
      #        url = quick_add_form_transactions_path
       #       render js: "window.location.pathname='#{url}'"
        @save_success = true
          respond_to do |format|
              format.js {render layout: false}
          end 
      else
        url = report_page_contact_path(:id => @trans.contact_id)
        render js: "window.location.pathname='#{url}'"
      end  
      #render js: "window.location.pathname='#{transactions_path}'"

      
    rescue Exception => e
     p e.to_s
     @serr = e.to_s
     respond_to do |format|
       format.js {render layout: false}

     end  
   end
    

    
    #redirect_to :action => 'index'

  end

 def update
   @trans = Transaction.find(params[:id])
   txn_ids = []
   params[:txn_items].each{|key,val|

      id = key.to_i
      txn_ids << id
      
     
      if id.to_i < 1000 
        ti = TxnItem.new(val)
        ti.created_by = @auser.id
        ti.calculate_amount
        ti.save!
        @trans.txn_items <<   ti
        txn_ids << ti.id
      else
         old_txi = TxnItem.find(id)  
         
         if old_txi.item_id != val[:item_id].to_i || old_txi.price != val[:price].to_f || old_txi.number != val[:number].to_i
           val[:updated_by] = @auser.id
           val[:amount] = val[:price].to_f * val[:number].to_i
           val[:buyback_was] = @trans.buyback
           val[:buyback_now] = params[:transaction][:byback].to_i
           old_txi.update_attributes(val)          
         end          
      end 
    
    } unless  params[:txn_items].blank?

      @trans.txn_items.each{|txn|
        txn.destroy if  !txn_ids.include?(txn.id)
      }

     site_param = params[:txn][:site]

     if !site_param.blank? and  site_param.length > 3
       site = Site.find_by_name(site_param)
   
       if site == nil
         site = Site.new
         site.name = site_param
         site.save!
       end 
       params[:transaction][:site_id] = site.id

     end

    begin  
     p "CALLING 1"
     @trans.skip_updator = true
     @trans.save!
     #@trans(params[:transaction])
     p "CALLING 2"
     @trans.skip_updator = false
     @trans.update_attributes(params[:transaction])


     render js: "window.location.pathname='#{transactions_path}'"
    rescue Exception => e
     p e.to_s
     @serr = e.to_s
       respond_to do |format|
         format.js {render layout: false}

       end  
    end
  
 end

 def destroy
 end

def remove
  #begin
    txn = Transaction.find(params[:id])
    cid = txn.contact_id
    txn.destroy
   flash[:notice] = 'Transaction# '+params[:id]+' deleted Successfully !'
   flash.keep(:notice)
   if(params[:show_page] == 'report_page')
     redirect_to  report_page_contact_path(:id => cid)
   else
    redirect_to :action => 'index'
   end 
   
  
#  rescue Exception => e 
 #   p e.to_s
  #  p e.backtrace
  #end  
 end

 def add_item_row
   row_no = params[:no]
   @row_no = row_no.to_i + 1
   @txn_item = TxnItem.new 
   respond_to do |format|
     format.js {render layout: false}
   end
 end 

 def search_contact
   contacts = Contact.trns_search(params[:str])
   respond_to do |format|
      format.json {render layout: false}
   end   

 end 

 def pagination
   
  @sort_column = params[:sort_colum] || 'on_date'
  @sort_order = params[:sort_order]  || "DESC"
  @page_size = params[:page_size] || 20

  no_of_weeks =  params[:no_of_weeks].blank? ? 2 : params[:no_of_weeks].to_i
  date_str = "on_date > '"+no_of_weeks.weeks.ago.strftime("%Y-%m-%d")+"' " if no_of_weeks > 1
  @trs_text = "Showing  transactions from last "+no_of_weeks.to_s+" weeks ."
  
  date_str = "on_date >  '"+1.months.ago.strftime("%Y-%m-%d")+"'" if params[:month_ago] == 'true'

  if !params[:from_date].blank? || !params[:to_date].blank?
    from_date = ( params[:from_date].blank? ?  '2000-01-01': DateTime.parse(params[:from_date]).strftime('%Y-%m-%d %H:%M'))
    to_date   = ( params[:to_date].blank? ? '2100-01-01' : DateTime.parse(params[:to_date]).strftime('%Y-%m-%d %H:%M') )
    date_str  = "on_date  between '"+from_date+"' and '"+to_date+"'"
    @trs_text = "Showing transactions "
    @trs_text += " from "+params[:from_date] if  !params[:from_date].blank?
    @trs_text += " up to "+params[:to_date] if  !params[:to_date].blank?
  end

   @trs = Transaction.where(date_str).order("#{@sort_column} #{@sort_order}, created_at DESC ")

   respond_to do |format|
      format.js {render layout: false}
   end 
 end 

 def quick_add_form

  @trans = Transaction.new
  @cont = Contact.all_conts
  @sites = Site.all
   
 end 

 def quick_add
 end


 
end
