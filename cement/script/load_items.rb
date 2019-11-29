#!/usr/bin/env ruby
require File.expand_path( '../../config/boot',__FILE__)
require  File.expand_path( '../../config/environment',__FILE__)

require 'csv'

csv_text = File.read('data/vas_items.csv')
csv = CSV.parse(csv_text, :headers => false)
p csv.count
csv.each do |row|
  if !row[0].blank?
  	c = Item.new
  	c.name = row[0].strip
  	c.description = row[1].strip if !row[1].blank?
  	c.item_type = row[2].strip if !row[2].blank?
  	p row
  	c.save!
  	p "sss"
  end
  	
end