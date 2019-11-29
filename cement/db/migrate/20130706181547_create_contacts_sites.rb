class CreateContactsSites < ActiveRecord::Migration
  def change
    create_table :contacts_sites do |t|
      t.integer :contact_id
      t.integer :site_id
      t.text    :contact_type
      t.timestamps
    end
  end
end
