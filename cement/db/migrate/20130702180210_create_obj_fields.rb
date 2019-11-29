class CreateObjFields < ActiveRecord::Migration
  def change
    create_table :obj_fields do |t|
      t.integer obj_id
      t.

      t.timestamps
    end
  end
end
