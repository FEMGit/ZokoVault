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

ActiveRecord::Schema.define(version: 20160909023152) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contacts", force: :cascade do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "emailaddress"
    t.string   "phone"
    t.string   "contact_type"
    t.string   "relationship"
    t.string   "beneficiarytype"
    t.string   "ssn"
    t.date     "birthdate"
    t.string   "address"
    t.string   "zipcode"
    t.string   "state"
    t.text     "notes"
    t.string   "avatarcolor"
    t.string   "photourl"
    t.string   "businessname"
    t.string   "businesswebaddress"
    t.string   "businessphone"
    t.string   "businessfax"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "user_id"
    t.integer  "relationship_id"
    t.string   "business_street_address"
    t.string   "city"
  end

  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "folder_id"
    t.string   "name",        null: false
    t.text     "description"
    t.string   "url",         null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "category"
    t.string   "group"
  end

  add_index "documents", ["folder_id"], name: "index_documents_on_folder_id", using: :btree
  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree

  create_table "folders", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.string   "type"
    t.string   "name",                        null: false
    t.text     "description"
    t.boolean  "system",      default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "folders", ["parent_id"], name: "index_folders_on_parent_id", using: :btree
  add_index "folders", ["user_id"], name: "index_folders_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shares", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "contact_id"
    t.string   "permission"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
  end

  add_index "shares", ["user_id"], name: "index_shares_on_user_id", using: :btree

  create_table "uploads", force: :cascade do |t|
    t.string  "name"
    t.text    "description"
    t.string  "folder"
    t.string  "url"
    t.integer "user_id"
  end

  add_index "uploads", ["user_id"], name: "index_uploads_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "vault_files", force: :cascade do |t|
    t.string "name"
    t.text   "description"
    t.string "folder"
    t.string "url"
  end

  create_table "vendor_accounts", force: :cascade do |t|
    t.string   "name"
    t.string   "group"
    t.string   "category"
    t.integer  "vendor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vendor_accounts", ["vendor_id"], name: "index_vendor_accounts_on_vendor_id", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.string   "category"
    t.string   "group"
    t.string   "name"
    t.string   "webaddress"
    t.string   "phone"
    t.integer  "contact_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vendors", ["contact_id"], name: "index_vendors_on_contact_id", using: :btree
  add_index "vendors", ["user_id"], name: "index_vendors_on_user_id", using: :btree

  add_foreign_key "contacts", "users"
  add_foreign_key "shares", "users"
  add_foreign_key "uploads", "users"
  add_foreign_key "vendor_accounts", "vendors"
  add_foreign_key "vendors", "contacts"
  add_foreign_key "vendors", "users"
end
