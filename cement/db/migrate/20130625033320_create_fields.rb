class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.text :name
      t.text :value_type
      t.boolean :is_deleted
      t.timestamps
    end
  end
end
