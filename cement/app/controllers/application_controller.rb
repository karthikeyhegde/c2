class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize, :clear_thread ,:accessable


  private

  def clear_thread
  end  

  def authorize
 
     if session[:user_id].nil?
        redirect_to :controller => 'users', :action => 'ask_signin'
        return
     end 
     @auser = User.find(session[:user_id])
     Thread.current[:auser] = nil
     User.current_user= @auser
     p "IIII"
     p @auser.id

  end	

  def accessable
    p "Params xxxx"
    p params
    ra = RoleAccess.where("role = ? and controller = ? and action = ? and allow = 0 ",@auser.role,params[:controller],params[:action])
    p ra
    redirect_to :controller => 'users', :action => 'no_access' if ra.size > 0

  end  



end
