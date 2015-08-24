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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150819190859) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "group_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.integer "permission_id", default: 1
  end

  create_table "groups", force: :cascade do |t|
    t.string  "name"
    t.boolean "public", default: true
  end

  create_table "issues", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "start_date"
    t.datetime "finish_date"
    t.string   "image_url"
    t.integer  "creator_id"
    t.integer  "group_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "issues", ["creator_id"], name: "index_issues_on_creator_id", using: :btree
  add_index "issues", ["group_id"], name: "index_issues_on_group_id", using: :btree

  create_table "permissions", force: :cascade do |t|
    t.string   "role"
    t.string   "can_create_issue"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "image_url"
    t.string   "first_name"
    t.string   "string"
    t.string   "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer  "issue_id"
    t.integer  "user_id"
    t.string   "ancestry"
    t.string   "value",      default: "abstain"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "votes", ["ancestry"], name: "index_votes_on_ancestry", using: :btree
  add_index "votes", ["issue_id"], name: "index_votes_on_issue_id", using: :btree
  add_index "votes", ["user_id"], name: "index_votes_on_user_id", using: :btree

end
