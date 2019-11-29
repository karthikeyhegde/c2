class SitesController < ApplicationController


  def index
    @sites = Site.all
  end

  def show
  end

  def edit
    @site = Site.find(params[:id])
    @form_method = 'update'
  end

  def new
    @site = Site.new
    @form_method = 'post'
  end

  def create
    @site = Site.new(params[:site])
    @site.save!
    redirect_to :action => 'index'
  end

  def update
    @site = Site.find(params[:id])
    @site.update_attributes(params[:site])
    redirect_to :action => 'index'
  end

  def search_names

    sites = Site.where("name like '#{params[:str]}%'").select("id,name").order('name asc').limit(10)
    respond_to do |format|
      format.json {render :json => sites.to_json}
   end  
  end  

  def remove
    Site.find(params[:id]).destroy
    redirect_to :action => 'index'
  end

  def destroy
  end

  def window_list
    @sites = Site.order("name")
    respond_to do |format|
      format.js {render layout: false}
   end 
  end  

  def rep_txnitems
      @site = Site.find(params[:id])
      @trs = Transaction.where(["site_id = ?",@site.id])
      @txn_items = @site.rep_txnitems 
  end

  def contact_txnitems
      @site = Site.find(params[:id])
      @contact =  Contact.find(params[:contact_id]) 
      @trs = Transaction.where(["site_id = ? and contact_id = ?",@site.id,params[:contact_id].to_i])
      @txn_items = @site.rep_txnitems params[:contact_id]
  end  


end
