
class MySetting < ActiveRecord::Base

	 has_many :child_settings, :class_name => :MySetting, :foreign_key => :parent_id
	 belongs_to :parent, :class_name => :MySetting, :foreign_key => :parent_id

	 
end
