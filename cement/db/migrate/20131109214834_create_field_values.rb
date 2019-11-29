class CreateFieldValues < ActiveRecord::Migration
  def change
    create_table :field_values do |t|
      t.integer :transaction_id
      t.integer :custom_field_id
      t.string  :field_name 
      t.string  :field_type

      t.string   :string_val, :limit => nil
      t.integer  :integer_val
      t.decimal  :decimal_val
      t.text     :text_val, :limit => 16777215
      t.time     :time_val
      t.date     :date_val
      t.datetime :datetime_val
      t.boolean  :boolaen_val


      t.timestamps
    end
  end
end
