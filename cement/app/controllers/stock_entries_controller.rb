class StockEntriesController < ApplicationController


 def index
  @sort_column = params[:sort_colum] || 'on_date'
  @sort_order = params[:sort_order]  || "DESC"
  @page_size = params[:page_size] || 20

  no_of_weeks =  params[:no_of_weeks].blank? ? 52 : params[:no_of_weeks].to_i
  date_str = "on_date > '"+no_of_weeks.weeks.ago.strftime("%Y-%m-%d")+"' " 
  @trs_text = "Showing  Stock Entries from last "+no_of_weeks.to_s+" weeks ."
  
  if !params[:from_date].blank? || !params[:to_date].blank?
    from_date = ( params[:from_date].blank? ?  '2000-01-01': DateTime.parse(params[:from_date]).strftime('%Y-%m-%d %H:%M'))
    to_date   = ( params[:to_date].blank? ? '2100-01-01' : DateTime.parse(params[:to_date]).strftime('%Y-%m-%d %H:%M') )
    date_str  = "on_date  between '"+from_date+"' and '"+to_date+"'"
    @trs_text = "Showing Stock Entries "
    @trs_text += " from "+params[:from_date] if  !params[:from_date].blank?
    @trs_text += " up to "+params[:to_date] if  !params[:to_date].blank?
  end
  offset = params[:offset] || 0
  total = StockEntry.count
  @stock_entries = StockEntry.where(date_str).order("#{@sort_column} #{@sort_order}, created_at DESC ")
  
 end

 def show
 end

 def new
  @stock_entry = StockEntry.new
  @cont = Contact.where('supplier = 1')
  @form_method = 'post'
 end

 def create
   begin
    @stock_entry = StockEntry.new(params[:stock_entry])
    @stock_entry.save!
    flash[:notice] = 'StockEntry #'+@stock_entry.id.to_s+' added Successfully !'
    flash.keep(:notice)
   rescue Exception => e
     p e.to_s
     p e.backtrace
   end 
   url = stock_entries_path
   render js: "window.location.pathname='#{url}'"
 end

 def edit
   @stock_entry=  StockEntry.find(params[:id])
   @form_method = 'update'
   @cont = Contact.all_conts
 end

 def update
   @stock_entry= StockEntry.find(params[:id])
   @stock_entry.update_attributes(params[:stock_entry])
   redirect_to :action => 'index'
 end

 def destroy
   redirect_to :action => 'index'
 end

 def remove
   StockEntry.find(params[:id]).destroy
   redirect_to :action => 'index'
 end

 def contact_stock
   @stock_entries = StockEntry.where("contact_id = ?",params[:id].to_i)
   @contact = Contact.find(params[:id].to_i)
   @show_val = 'stks'
   @report = Report.new()
   render :template => 'contacts/report_page.erb'

 end 

end	