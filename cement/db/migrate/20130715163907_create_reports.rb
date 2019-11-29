class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :name
      t.integer :created_by
      t.boolean :show
      t.boolean :is_saved

      t.timestamps
    end
  end
end
