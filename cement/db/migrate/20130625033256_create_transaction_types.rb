class CreateTransactionTypes < ActiveRecord::Migration
  def up
    create_table :transaction_types do |t|
       t.string :name
       t.text :description 
       t.integer :created_by
       t.integer :modified_by
       t.timestamps
    end
  end

  def down
  	drop_table :transaction_types
  end	
end
