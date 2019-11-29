class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.text :name
      t.text :contact_type
      t.text :parent_id
      t.text :address
      t.text :place
      t.text :contact_number
      t.text :contact_number2
      t.timestamps
    end
  end
end
