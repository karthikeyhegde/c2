#!/usr/bin/env ruby
require File.expand_path( '../../config/boot',__FILE__)
require  File.expand_path( '../../config/environment',__FILE__)

  

 require 'net/pop'
 require 'mail'
 require 'yaml'
 
 require  File.expand_path( '../method_actions',__FILE__)

fn = File.dirname(File.expand_path(__FILE__)) + '/de.yml'
cnf = YAML::load(File.open(fn))




     email_hash = {}

      username = '9karthi@gmail.com'
      password = 'my9a55word'
      @connection = Net::POP3.new('pop.gmail.com', 995)
      @connection.enable_ssl(OpenSSL::SSL::VERIFY_NONE) 
      @connection.start(username, password)
      i = 0
      @connection.mails.each{|a| 
      
      i += 1
      email = Mail.new(a.pop)
      body =  email.body.decoded.split("\n\n")[1]
      email_hash[i] = {:subject => email.subject,:mail_body => body, :from => email.from}

      
      }

  i = 0
      email_hash.each{|email|
       p "e"   
       p email[1]
       p email[1][:subject]
       action,obj = check_for_subject_syntax(cnf,email[1][:subject])
       p "MMM"
       p action
       p obj
       call_object_action(cnf,obj,action,email[1][:mail_body]) if (!action.blank? and !obj.blank?)

      
      }