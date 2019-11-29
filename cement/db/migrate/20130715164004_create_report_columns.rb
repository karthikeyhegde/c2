class CreateReportColumns < ActiveRecord::Migration
  def change
    create_table :report_columns do |t|
      t.integer :report_id
      t.string  :obj_name
      t.string  :column_name
      t.timestamps
    end
  end
end
