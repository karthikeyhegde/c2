class UserMailer < ActionMailer::Base
  

  default from: 'mailer.vardhanagencies@gmail.com'
  

  def welcome_email(user)
  	@user = user
    mail(to: @user.email, subject: 'Welcome to Vanitha Reminders, Sirsi')
  end

  def password_reset(user)
  	@user = user
    mail(to: @user.email, subject: 'Vardhan Reminders, Sirsi Your password has been reseted')
  end	

  def daily_report(to_email,message,subject)
   @message = message
   mail(to: to_email, subject: subject)
  end


end
