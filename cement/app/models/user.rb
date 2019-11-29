
require 'bcrypt'
class User < ActiveRecord::Base

   attr_accessor :password, :password_confirmation
   include BCrypt
  
   include BaseUtils
   
   audited :allow_mass_assignment => true

   before_save :encrypt_password

  

  validates_confirmation_of :password
  validates_presence_of :email, :message => "Email Address can not be blank "
  validates_length_of :username ,:minimum => 4, :message => "Username should have minimum 4 charector"
  #validates_uniqueness_of :email, :message => "Email #{self.email} already registered. Please enter a different one"
 # validates_uniqueness_of :username, :message => "Username #{self.username} already exists. Please enter a  different one."


  def generate_password
  	self.password =  (('0'..'9').to_a+('A'..'Z').to_a+('a'..'z').to_a).shuffle.first(6).join
  	p "Password"
  	p self.password
  end

  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def send_creational_email
  end	

  def self.authenticate(username, password)
    user = find_by_username(username)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end



   def self.current_user
   	  Thread.current[:auser]
   end	
  
   def self.current_user= user
   	  Thread.current[:auser] = user
   end

   
  


end
