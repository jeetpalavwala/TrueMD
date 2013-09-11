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

ActiveRecord::Schema.define(:version => 20130624180901) do

  create_table "api_users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "api_key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "drugs", :force => true do |t|
    t.string  "manufacturer"
    t.string  "brand"
    t.string  "category"
    t.string  "d_class"
    t.float   "unit_qty"
    t.string  "unit_type"
    t.float   "package_qty"
    t.string  "package_type"
    t.float   "package_price"
    t.float   "unit_price"
    t.integer "generic_id"
  end

  add_index "drugs", ["brand"], :name => "brand"
  add_index "drugs", ["generic_id"], :name => "generic_id"

  create_table "generics", :force => true do |t|
    t.string  "generic_id"
    t.integer "qty"
    t.string  "name"
    t.string  "strength"
  end

  add_index "generics", ["generic_id"], :name => "generic_id"
  add_index "generics", ["name"], :name => "name"
  add_index "generics", ["qty"], :name => "qty"
  add_index "generics", ["strength"], :name => "strength"

  create_table "user_sessions", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
