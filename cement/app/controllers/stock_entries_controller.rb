class StockEntriesController < ApplicationController


 def index
  @sort_column = params[:sort_colum] || 'on_date'
  @sort_order = params[:sort_order]  || "DESC"
  @page_size = params[:page_size] || 20

  values = Utility.pagination_process(params,"Stock Entries")
  @trs_text = values[1]
  total = StockEntry.count
  @stock_entries = StockEntry.where(values[0]).order("#{@sort_column} #{@sort_order}, created_at DESC ")
  
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

  def pagination
    @sort_column = params[:sort_colum] || 'on_date'
    @sort_order = params[:sort_order]  || "DESC"
    @page_size = params[:page_size] || 20
    @offset = params[:offset] || 0
    
    values = Utility.pagination_process(params,"Stock Entries")
    @trs_text = values[1]
    total = StockEntry.count
    @stock_entries = StockEntry.where(values[0]).order("#{@sort_column} #{@sort_order}, created_at DESC ")
  respond_to do |format|
      format.js {render layout: false}
   end 
  end  

end	