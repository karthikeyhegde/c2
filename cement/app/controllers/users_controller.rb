class UsersController < ApplicationController
    skip_before_filter :authorize , only: [:ask_signin,:enter_in]
    skip_before_filter :accessable, only: [:no_access,:ask_signin, :enter_in]

 def index
 	 @users = User.all
 end
 
 def show
 end	

 def new
  raise 'You are not authorized to do this' if @auser.role  != 'Admin'
 	@user = User.new
 end
 
 def create
  raise 'You are not authorized to do this' if @auser.role  != 'Admin'
 	params[:user]['change_password'] = '1'
 	@user = User.new(params[:user])
 	if @user.valid?
	 	 @user.generate_password
     UserMailer.welcome_email(@user).deliver
	 	 @user.save!
	 	
	else 
       @user.errors.each{|e|   e}
	     render new
	end	
 	redirect_to :controller=> 'users', :action => 'index'
 end

 def edit
   raise 'You are not authorized to do this' if @auser.role  != 'Admin'
   @user = User.find(params[:id])
 end	

 def update
    raise 'You are not authorized to do this' if @auser.role  != 'Admin'
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    flash[:info] = "Updated the user #{@user.full_name}'s details successfully"
    redirect_to :controller=> 'users', :action => 'index'

 end

 def destroy
  raise 'You are not authorized to do this' if @auser.role  != 'Admin'
 end	

def remove
  raise 'You are not authorized to do this' if @auser.role  != 'Admin'
   User.find(params[:id]).destroy
   redirect_to :action => 'index'
 end

 def inactivate
  raise 'You are not authorized to do this' if @auser.role  != 'Admin'
 	a = User.find(params[:id])
    a.active = 0
    a.save!
   redirect_to :action => 'index'
 end
 
 def activate
  raise 'You are not authorized to do this' if @auser.role  != 'Admin'
 	a = User.find(params[:id])
    a.active = 1
    a.save!
   redirect_to :action => 'index'
 end	


 def welcome	
 	redirect_to  :controller => 'transactions', :action => "index" , :user => @user 
 end

 def ask_signin
 end	


   def enter_in

  p " In enter in"
  p request.remote_ip()
 	@user = User.authenticate(params[:username], params[:password])


 	if @user.nil?
 		flash[:error] = "Invalid username or password"
 		redirect_to :action => "ask_signin"
  elsif  @user.restriction_type == 'IP ADDRESS' && @user.allowed_ip != request.remote_ip()
    flash[:error] = "Please try to login within known network"
      redirect_to :action => "ask_signin" 

 	elsif @user.change_password == 1
       session[:user_id] = @user.id
       redirect_to :action => 'change_password', :id => @user.id     
  else	
      session[:user_id] = @user.id
 	    redirect_to  :controller => 'transactions', :action => "index" , :user => @user		
  end		
    return
  end	


  def no_access
  end 

  def reset_password
   
   begin
    raise 'You are not authorized to do this' if @auser.role  != 'Admin'
    @user = User.find(params[:id])
    @user.generate_password
    @user.change_password = 1
    UserMailer.password_reset(@user).deliver
    @user.save!
    flash[:info] = 'Password has been reset successfully for '+@user.full_name
    flash[:info] += "  Email has been sent to "+@user.email
   rescue Exception => e
     flash[:info] = "Password reset was UNSUCCESS. "+e.to_s
   end 
   redirect_to :action => 'index'
  end  

  def change_password
     @user =  User.find(params[:id])
  end	
  
  def save_new_password
    flash[:error] = ''
    flash[:info] = ''
    begin
      params[:user][:change_password] = 0
      @user = User.find(params[:id])
      raise 'You are not authorized to change the password for this user' if @user.id != @auser.id
      @user.update_attributes(params[:user])
      flash[:info] = 'Password changed successfully, Use new password with you next login'
      session[:user_id] = nil
      @user = User.find(params[:id])
      render :template =>  'users/welecome.erb'
     rescue Exception => e 
       flash[:error] = 'Password didnot changed, Try again. '+e.to_s
       redirect_to :action => 'change_password', :id => @user.id
     end 
  end	

  def logout
    session[:user_id] = nil
    @auser = nil
    flash[:error] = "Log out Successfull"
    redirect_to :action => "ask_signin"
  end  

  def sel_details
  end  

end
