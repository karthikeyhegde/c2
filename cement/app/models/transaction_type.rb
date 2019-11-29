class TransactionType < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :custom_fields,  :dependent => :destroy
  has_many :field_values
  has_one :creater, :class_name => "User", :foreign_key => 'created_by'
  has_one :modifier, :class_name => "User", :foreign_key => 'modified_by'

  
end
