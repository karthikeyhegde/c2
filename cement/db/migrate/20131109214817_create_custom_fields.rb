class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.string  :name
      t.string  :val_type
      t.timestamps
    end
  end
end
