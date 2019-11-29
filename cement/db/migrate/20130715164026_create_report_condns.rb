class CreateReportCondns < ActiveRecord::Migration
  def change
    create_table :report_condns do |t|
      t.integer :report_id
      t.string  :obj_name
      t.string  :column
      t.string  :col_type
      t.string  :start_val
      t.string  :end_val
      t.timestamps
    end
  end
end
