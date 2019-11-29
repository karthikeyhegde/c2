#!/usr/bin/env ruby
require File.expand_path( '../../config/boot',__FILE__)
require  File.expand_path( '../../config/environment',__FILE__)

require 'csv'

csv_text = File.read('data/vas_contacts.csv')
csv = CSV.parse(csv_text, :headers => false)
p csv.count
csv.each do |row|
  if !row[0].blank?
  	c = Contact.new
  	c.name = row[0].strip
  	c.subname = row[1].strip if !row[1].blank?
  	p row
  	c.save!
  	p "sss"
  end
  	
end