class ItemsController < ApplicationController


 def index
  @items = Item.order(:name)
 end

 def show
 end

 def new
  @item = Item.new
  @form_method = 'post'
 end

 def create
  @item = Item.new(params[:item])
  default_date = MySetting.find_by_name('stock_start_date')
  @item.start_date = default_date.value;
  @item.save!
  redirect_to :action => 'index'
 end

 def edit
  @item = Item.find(params[:id])
  @form_method = 'update'
 end

 def update
  @item = Item.find(params[:id])
  @item.update_attributes(params[:item])
  redirect_to :action => 'index'
 end

 def destroy
  redirect_to :action => 'index'
 end

 def remove
   begin
   Item.find(params[:id]).destroy
   redirect_to :action => 'index'
 rescue Exception => e
  flash[:message] = e.to_s
  redirect_to({ action: 'index' }, message: "Something serious happened")
   p e.to_s
 end 
 end

 def edit_items_all
   @items = Item.order(:name)
   @default_date = MySetting.find_by_name('stock_start_date')
   p @default_date.value
 end 

 def set_default_date
  @default_date = MySetting.find_by_name('stock_start_date')
  @default_date.value = params[:d_date]
  @default_date.save!

  Item.mass_update_currentstock

  redirect_to :action => 'edit_items_all'
 end

 def quick_save_item
   id = params[:id].to_i
    @item = Item.find(id);
    @item.starting_stock = params[:start_stock].to_i
    @item.start_date = DateTime.parse(params[:start_date])
    p "SAVING"
    @item.save!
    @item.update_stockentry_fromdate
    respond_to do |format|
        format.json { render json: @item }
    end
 end 

 def recalculate_currentstock
  
  redirect_to :action => 'edit_items_all'
 end


 def rep_txnitems

    @item = Item.find(params[:id])
    sdate = nil
    edate = Time.now
  if (params.has_key?(:sdate) && params[:sdate] != nil && params[:sdate] != '' )
    sdate = DateTime.parse(params[:sdate]).strftime('%Y-%m-%d %H:%M') 
    edate = DateTime.parse(params[:edate]).strftime('%Y-%m-%d %H:%M')  if(params.has_key?(:edate) && params[:edate] != nil && params[:edate] != '' )
  else
      if( @item.txn_items.length() >  100)
        sdate = 2.months.ago
        edate = Time.now
        params[:sdate] = DateTime.parse(sdate.to_s).strftime("%d-%m-%Y")
        params[:edate] = DateTime.parse(edate.to_s).strftime("%d-%m-%Y")

      end
  end  

    @txn_items = @item.rep_ixnitems sdate, edate
    @all_sum = 0
    @all_numbers = 0
    @txn_items.each{|s| 
      @all_sum +=  (s.transaction.buyback == 1 ? (-1 * s.amount.to_f) : s.amount.to_f)
      @all_numbers += ( s.transaction.buyback == 1 ? (-1 * s.number.to_i) : s.number.to_i)
    }
    
 end 

 def filter_rep_txnitems
  p "FROM FILTER"
    rep_txnitems
    render template:  'items/rep_txnitems'
 end

 def stock_entries
  @item = Item.find(params[:id].to_i)
  @stock_entries = @item.stock_entries
  render template: 'stock_entries/list'
 end 

 def all_search
    search_str = params[:search]
    ssearch = '%'+search_str+'%'
    @contacts = Contact.where(" LOWER (name) LIKE  LOWER (?)  OR LOWER (subname)  LIKE LOWER (?) OR LOWER (place) LIKE LOWER (?) OR LOWER (contact_type) LIKE LOWER (?)",ssearch,ssearch,ssearch,ssearch)
    @items = Item.where(" LOWER (name)  LIKE LOWER(?)",ssearch)
    @sites = Site.where(" LOWER (name) LIKE LOWER (?) OR LOWER (place) LIKE LOWER (?) ",ssearch,ssearch )
    @trs = @transaction = Transaction.where('id = ?',params[:search].to_i)
 end 


 def aggrigated_summary
   required_params = params.slice(:site_id,:contact_id,:from_date,:to_date)
   @summary =   Item.summary required_params
   @all_sum = 0
   @summary.each{|s| @all_sum += s['t_sum'].to_f}
 end 

 def stock_entries_list
    @stock_entries  = StockEntry.list ({:item_id => parmas[:id]})   
 end


def ajax_reptxn
  p "FROM AJAX"
  rep_txnitems
  respond_to do |format|
         format.js {render layout: false}
  end  
end

def ajax_stockentry
  @item = Item.find(params[:id].to_i)
  res = @item.stock_entries_with_total
  p "STK entries "
  p res
  @item_stock_entries = res["stockentries"]
  @total = res["total"]
  respond_to do |format|
         format.js {render layout: false}
  end  
end  
 


end
