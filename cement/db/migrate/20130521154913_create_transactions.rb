class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.date     :on_date
      t.integer  :item_id
      t.decimal  :price
      t.integer  :quantity
      t.integer  :created_by
      t.integer  :modified_by
      t.text     :place
      t.text     :descri
      t.integer  :bill_id
      t.integer  :contact_id
      t.integer  :sub_contact_id
      t.integer  :site_id
      t.timestamps
    end
  end
end
