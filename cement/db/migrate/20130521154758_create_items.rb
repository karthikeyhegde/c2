class CreateItems < ActiveRecord::Migration
  def up
    create_table :items do |t|
      t.string :name
      t.text   :description
      t.text   :item_type
      t.text   :created_by
      t.text   :modified_by
      t.timestamps
    end
  end

  def down
    drop_table :items
  end
end
