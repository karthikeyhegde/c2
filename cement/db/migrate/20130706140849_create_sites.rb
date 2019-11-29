class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string  :name
      t.text    :address
      t.string  :place
      t.date    :start_date
      t.timestamps
    end
  end
end
