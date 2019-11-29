module BaseUtils
    attr_accessor :skipp_updator
 	def self.included(base)
 		base.before_create :assign_created_user
 		base.before_update :assign_updated_user
 	end

 	def assign_created_user
 		self.created_by = Thread.current[:auser].id if !Thread.current[:auser].nil?
 	end 
 	
 	def assign_updated_user
 		self.updated_by = Thread.current[:auser].id if !Thread.current[:auser].nil? and @skipp_updator != true
 	end	

end