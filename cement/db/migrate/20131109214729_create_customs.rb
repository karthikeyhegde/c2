class CreateCustoms < ActiveRecord::Migration
  def change
    create_table :customs do |t|
      t.string :fields

      t.timestamps
    end
  end
end
