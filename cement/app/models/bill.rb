class Bill < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :transaction
  has_many :items

end
