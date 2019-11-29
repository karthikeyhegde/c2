# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140629070316) do

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "bills", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "name",            :limit => 250
    t.text     "contact_type"
    t.text     "parent_id"
    t.text     "address"
    t.text     "place"
    t.string   "subname",         :limit => 250
    t.text     "contact_number"
    t.text     "contact_number2"
    t.text     "email"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "contacts_sites", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "site_id"
    t.text     "contact_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "custom_fields", :force => true do |t|
    t.string   "name"
    t.string   "val_type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "customs", :force => true do |t|
    t.string   "fields"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "field_values", :force => true do |t|
    t.integer  "transaction_id"
    t.integer  "custom_field_id"
    t.string   "field_name"
    t.string   "field_type"
    t.string   "string_val"
    t.integer  "integer_val"
    t.decimal  "decimal_val",                         :precision => 10, :scale => 0
    t.text     "text_val",        :limit => 16777215
    t.time     "time_val"
    t.date     "date_val"
    t.datetime "datetime_val"
    t.boolean  "boolaen_val"
    t.datetime "created_at",                                                         :null => false
    t.datetime "updated_at",                                                         :null => false
  end

  create_table "fields", :force => true do |t|
    t.text     "name"
    t.text     "value_type"
    t.boolean  "is_deleted"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "item_type"
    t.text     "created_by"
    t.text     "modified_by"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "obj_fields", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "payments", :force => true do |t|
    t.integer "transaction_id"
    t.integer "contact_id"
    t.date    "payment_date"
    t.string  "payment_type",   :limit => 250
    t.text    "info"
    t.integer "amount"
    t.integer "recieved",       :limit => 1
    t.integer "created_by"
    t.integer "modified_by"
  end

  create_table "report_columns", :force => true do |t|
    t.integer  "report_id"
    t.string   "obj_name"
    t.string   "column_name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "report_condns", :force => true do |t|
    t.integer  "report_id"
    t.string   "obj_name"
    t.string   "column"
    t.string   "col_type"
    t.string   "start_val"
    t.string   "end_val"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.integer  "created_by"
    t.boolean  "show"
    t.boolean  "is_saved"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "place"
    t.date     "start_date"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "transaction_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "created_by"
    t.integer  "modified_by"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "transactions", :force => true do |t|
    t.date     "on_date"
    t.integer  "txn_item_id"
    t.text     "descri"
    t.integer  "bill_id"
    t.integer  "contact_id"
    t.integer  "site_id"
    t.string   "other_charges",        :limit => 250
    t.integer  "other_charges_amount"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "created_by"
    t.integer  "updated_by"
  end

  create_table "txn_items", :force => true do |t|
    t.integer "item_id"
    t.integer "number"
    t.integer "price"
    t.integer "amount"
    t.integer "transaction_id"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "email"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
