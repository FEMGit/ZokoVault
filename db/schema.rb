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

ActiveRecord::Schema.define(version: 20170407160553) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "card_documents", force: :cascade do |t|
    t.integer  "card_id"
    t.integer  "user_id"
    t.string   "object_type"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "card_documents", ["user_id"], name: "index_card_documents_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

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
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id"
    t.integer  "relationship_id"
    t.string   "city"
    t.string   "business_street_address_1"
    t.string   "business_street_address_2"
    t.integer  "user_profile_id"
    t.integer  "full_primary_shared_id"
  end

  add_index "contacts", ["emailaddress"], name: "index_contacts_on_emailaddress", using: :btree
  add_index "contacts", ["full_primary_shared_id"], name: "index_contacts_on_full_primary_shared_id", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree
  add_index "contacts", ["user_profile_id"], name: "index_contacts_on_user_profile_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "documents", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "folder_id"
    t.string   "name",                     null: false
    t.text     "description"
    t.string   "url",                      null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "category"
    t.string   "group"
    t.integer  "card_document_id"
    t.integer  "vendor_id"
    t.integer  "financial_information_id"
  end

  add_index "documents", ["financial_information_id"], name: "index_documents_on_financial_information_id", using: :btree
  add_index "documents", ["folder_id"], name: "index_documents_on_folder_id", using: :btree
  add_index "documents", ["user_id"], name: "index_documents_on_user_id", using: :btree
  add_index "documents", ["vendor_id"], name: "index_documents_on_vendor_id", using: :btree

  create_table "employers", force: :cascade do |t|
    t.integer  "user_profile_id"
    t.string   "name"
    t.string   "web_address"
    t.string   "street_address_1"
    t.string   "street_address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone_number_office"
    t.string   "phone_number_fax"
    t.string   "notes"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "entities", force: :cascade do |t|
    t.string   "name"
    t.string   "notes"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "entities", ["category_id"], name: "index_entities_on_category_id", using: :btree
  add_index "entities", ["user_id"], name: "index_entities_on_user_id", using: :btree

  create_table "final_wish_infos", force: :cascade do |t|
    t.string   "group"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.integer  "category_id"
  end

  add_index "final_wish_infos", ["category_id"], name: "index_final_wish_infos_on_category_id", using: :btree
  add_index "final_wish_infos", ["user_id"], name: "index_final_wish_infos_on_user_id", using: :btree

  create_table "final_wishes", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "user_id"
    t.integer  "primary_contact_id"
    t.string   "notes"
    t.integer  "final_wish_info_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "category_id"
  end

  add_index "final_wishes", ["category_id"], name: "index_final_wishes_on_category_id", using: :btree

  create_table "financial_account_informations", force: :cascade do |t|
    t.integer  "account_type"
    t.integer  "owner_id"
    t.decimal  "value"
    t.string   "number"
    t.integer  "primary_contact_broker_id"
    t.string   "notes"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "user_id"
    t.integer  "account_provider_id"
    t.integer  "category_id"
    t.string   "name"
  end

  add_index "financial_account_informations", ["category_id"], name: "index_financial_account_informations_on_category_id", using: :btree
  add_index "financial_account_informations", ["user_id"], name: "index_financial_account_informations_on_user_id", using: :btree

  create_table "financial_account_owners", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "financial_account_owners", ["contact_id"], name: "index_financial_account_owners_on_contact_id", using: :btree

  create_table "financial_alternatives", force: :cascade do |t|
    t.integer  "alternative_type"
    t.string   "name"
    t.integer  "owner_id"
    t.decimal  "commitment"
    t.decimal  "total_calls"
    t.decimal  "total_distributions"
    t.decimal  "current_value"
    t.integer  "primary_contact_id"
    t.string   "notes"
    t.integer  "manager_id"
    t.integer  "user_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.integer  "category_id"
  end

  add_index "financial_alternatives", ["category_id"], name: "index_financial_alternatives_on_category_id", using: :btree
  add_index "financial_alternatives", ["user_id"], name: "index_financial_alternatives_on_user_id", using: :btree

  create_table "financial_investments", force: :cascade do |t|
    t.string   "name"
    t.integer  "investment_type"
    t.integer  "owner_id"
    t.decimal  "value"
    t.string   "web_address"
    t.string   "phone_number"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.integer  "primary_contact_id"
    t.string   "notes"
    t.integer  "user_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "empty_provider_id"
    t.integer  "category_id"
  end

  add_index "financial_investments", ["category_id"], name: "index_financial_investments_on_category_id", using: :btree
  add_index "financial_investments", ["user_id"], name: "index_financial_investments_on_user_id", using: :btree

  create_table "financial_properties", force: :cascade do |t|
    t.string   "name"
    t.integer  "property_type"
    t.integer  "owner_id"
    t.decimal  "value"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.integer  "primary_contact_id"
    t.string   "notes"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.integer  "empty_provider_id"
    t.integer  "category_id"
  end

  add_index "financial_properties", ["category_id"], name: "index_financial_properties_on_category_id", using: :btree
  add_index "financial_properties", ["user_id"], name: "index_financial_properties_on_user_id", using: :btree

  create_table "financial_providers", force: :cascade do |t|
    t.string   "name"
    t.string   "web_address"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.string   "phone_number"
    t.string   "fax_number"
    t.integer  "primary_contact_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "user_id"
    t.string   "type"
    t.integer  "category_id"
    t.integer  "provider_type"
  end

  add_index "financial_providers", ["category_id"], name: "index_financial_providers_on_category_id", using: :btree
  add_index "financial_providers", ["user_id"], name: "index_financial_providers_on_user_id", using: :btree

  create_table "health_policies", force: :cascade do |t|
    t.integer  "policy_type"
    t.string   "policy_number"
    t.string   "group_number"
    t.integer  "policy_holder_id"
    t.integer  "broker_or_primary_contact_id"
    t.string   "notes"
    t.integer  "vendor_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "group_id"
  end

  create_table "health_policies_insured_members", force: :cascade do |t|
    t.integer "health_policy_id"
    t.integer "insured_member_id"
  end

  create_table "interested_users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.string   "message"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "life_and_disability_policies", force: :cascade do |t|
    t.integer  "policy_type"
    t.integer  "policy_holder_id"
    t.decimal  "coverage_amount",              precision: 11, scale: 2
    t.string   "policy_number"
    t.integer  "broker_or_primary_contact_id"
    t.string   "notes"
    t.integer  "vendor_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "life_and_disability_policies_primary_beneficiaries", force: :cascade do |t|
    t.integer "life_and_disability_policy_id"
    t.integer "primary_beneficiary_id"
  end

  create_table "life_and_disability_policies_secondary_beneficiaries", force: :cascade do |t|
    t.integer "life_and_disability_policy_id"
    t.integer "secondary_beneficiary_id"
  end

  create_table "multifactor_phone_codes", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "multifactor_phone_codes", ["user_id"], name: "index_multifactor_phone_codes_on_user_id", using: :btree

  create_table "old_passwords", force: :cascade do |t|
    t.string   "encrypted_password",       null: false
    t.string   "password_archivable_type", null: false
    t.integer  "password_archivable_id",   null: false
    t.datetime "created_at"
    t.string   "password_salt"
  end

  add_index "old_passwords", ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable", using: :btree

  create_table "power_of_attorney_contacts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end
  
  add_index "power_of_attorney_contacts", ["category_id"], name: "index_power_of_attorney_contacts_on_category_id", using: :btree
  add_index "power_of_attorney_contacts", ["user_id"], name: "index_power_of_attorney_contacts_on_user_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stripe_id"
    t.string   "description"
    t.integer  "amount"
    t.string   "currency"
    t.boolean  "captured"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

  create_table "power_of_attorney_contacts", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "category_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "power_of_attorney_contacts", ["category_id"], name: "index_power_of_attorney_contacts_on_category_id", using: :btree
  add_index "power_of_attorney_contacts", ["user_id"], name: "index_power_of_attorney_contacts_on_user_id", using: :btree

  create_table "power_of_attorneys", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "power_of_attorney_id"
    t.hstore   "powers"
    t.integer  "user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.string   "notes"
    t.integer  "category_id"
  end

  add_index "power_of_attorneys", ["category_id"], name: "index_power_of_attorneys_on_category_id", using: :btree

  create_table "property_and_casualty_policies", force: :cascade do |t|
    t.integer  "policy_type"
    t.string   "insured_property"
    t.integer  "policy_holder_id"
    t.decimal  "coverage_amount",              precision: 11, scale: 2
    t.string   "policy_number"
    t.integer  "broker_or_primary_contact_id"
    t.string   "notes"
    t.integer  "vendor_id"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
  end

  create_table "relationships", force: :cascade do |t|
    t.string   "name"
    t.string   "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "share_invitation_sents", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "contact_email"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "user_invite_status"
  end

  add_index "share_invitation_sents", ["contact_email"], name: "index_share_invitation_sents_on_contact_email", using: :btree
  add_index "share_invitation_sents", ["user_id"], name: "index_share_invitation_sents_on_user_id", using: :btree

  create_table "shares", force: :cascade do |t|
    t.integer  "contact_id"
    t.string   "permission"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.integer  "shareable_id"
    t.string   "shareable_type"
  end

  add_index "shares", ["user_id"], name: "index_shares_on_user_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name_on_card"
    t.string   "last4"
    t.string   "customer_id"
    t.string   "stripe_token"
    t.string   "plan_id"
    t.string   "promo_code"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "tax_year_infos", force: :cascade do |t|
    t.integer  "year"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.integer  "category_id"
  end

  add_index "tax_year_infos", ["category_id"], name: "index_tax_year_infos_on_category_id", using: :btree
  add_index "tax_year_infos", ["user_id"], name: "index_tax_year_infos_on_user_id", using: :btree

  create_table "taxes", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "tax_preparer_id"
    t.string   "notes"
    t.integer  "user_id"
    t.integer  "tax_year_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "category_id"
  end

  add_index "taxes", ["category_id"], name: "index_taxes_on_category_id", using: :btree

  create_table "trusts", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "executor_id"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "notes"
    t.integer  "category_id"
  end

  add_index "trusts", ["category_id"], name: "index_trusts_on_category_id", using: :btree

  create_table "tutorials", force: :cascade do |t|
    t.string   "name"
    t.string   "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uploads", force: :cascade do |t|
    t.string  "name"
    t.text    "description"
    t.string  "folder"
    t.string  "url"
    t.integer "user_id"
  end

  add_index "uploads", ["user_id"], name: "index_uploads_on_user_id", using: :btree

  create_table "user_activities", force: :cascade do |t|
    t.integer  "user_id"
    t.date     "login_date"
    t.integer  "login_count"
    t.integer  "session_length"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "user_activities", ["user_id"], name: "index_user_activities_on_user_id", using: :btree

  create_table "user_death_traps", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "page_terminated_on"
    t.string   "error_message"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "user_death_traps", ["user_id"], name: "index_user_death_traps_on_user_id", using: :btree

  create_table "user_profile_security_questions", force: :cascade do |t|
    t.integer  "user_profile_id"
    t.string   "question"
    t.string   "answer"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.date     "date_of_birth"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "signed_terms_of_service_at"
    t.string   "phone_number"
    t.integer  "mfa_frequency"
    t.string   "ssn"
    t.string   "phone_number_mobile"
    t.string   "street_address_1"
    t.string   "street_address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "notes"
    t.string   "two_factor_phone_number"
  end

  create_table "user_traffics", force: :cascade do |t|
    t.string   "page_name"
    t.string   "page_url"
    t.string   "ip_address"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "shared_user_id"
  end

  add_index "user_traffics", ["shared_user_id"], name: "index_user_traffics_on_shared_user_id", using: :btree
  add_index "user_traffics", ["user_id"], name: "index_user_traffics_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",       null: false
    t.string   "encrypted_password",     default: "",       null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,        null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,        null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "setup_complete",         default: false
    t.boolean  "admin"
    t.string   "stripe_id"
    t.string   "subscription_status",    default: "unpaid"
    t.string   "subscription_type"
    t.datetime "paid_through"
    t.boolean  "auto_resubscribe",       default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree

  create_table "vault_entry_beneficiaries", force: :cascade do |t|
    t.integer  "will_id"
    t.boolean  "active"
    t.decimal  "percentage"
    t.integer  "type"
    t.integer  "contact_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "vault_entry_beneficiaries", ["contact_id"], name: "index_vault_entry_beneficiaries_on_contact_id", using: :btree
  add_index "vault_entry_beneficiaries", ["will_id"], name: "index_vault_entry_beneficiaries_on_will_id", using: :btree

  create_table "vault_entry_contacts", force: :cascade do |t|
    t.integer  "type"
    t.boolean  "active",           default: true
    t.integer  "contact_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "contactable_id"
    t.string   "contactable_type"
  end

  add_index "vault_entry_contacts", ["contact_id"], name: "index_vault_entry_contacts_on_contact_id", using: :btree
  add_index "vault_entry_contacts", ["type"], name: "index_vault_entry_contacts_on_type", using: :btree

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
    t.string   "group"
    t.string   "name"
    t.string   "webaddress"
    t.string   "phone"
    t.integer  "contact_id"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "fax"
    t.string   "street_address_1"
    t.string   "street_address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "type"
    t.integer  "category_id"
  end

  add_index "vendors", ["category_id"], name: "index_vendors_on_category_id", using: :btree
  add_index "vendors", ["contact_id"], name: "index_vendors_on_contact_id", using: :btree
  add_index "vendors", ["user_id"], name: "index_vendors_on_user_id", using: :btree

  create_table "wills", force: :cascade do |t|
    t.integer  "document_id"
    t.integer  "executor_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "notes"
    t.string   "title"
    t.integer  "category_id"
  end

  add_index "wills", ["category_id"], name: "index_wills_on_category_id", using: :btree

  create_table "words", force: :cascade do |t|
    t.string "word", null: false
  end

  add_foreign_key "card_documents", "users"
  add_foreign_key "contacts", "user_profiles", column: "full_primary_shared_id"
  add_foreign_key "contacts", "users"
  add_foreign_key "entities", "categories"
  add_foreign_key "entities", "users"
  add_foreign_key "final_wish_infos", "users"
  add_foreign_key "financial_account_owners", "contacts", on_delete: :cascade
  add_foreign_key "financial_alternatives", "users"
  add_foreign_key "financial_investments", "users"
  add_foreign_key "power_of_attorney_contacts", "categories"
  add_foreign_key "power_of_attorney_contacts", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "power_of_attorney_contacts", "categories"
  add_foreign_key "power_of_attorney_contacts", "users"
  add_foreign_key "shares", "users"
  add_foreign_key "tax_year_infos", "users"
  add_foreign_key "uploads", "users"
  add_foreign_key "user_activities", "users"
  add_foreign_key "user_death_traps", "users"
  add_foreign_key "user_traffics", "users"
  add_foreign_key "user_traffics", "users", column: "shared_user_id"
  add_foreign_key "vault_entry_beneficiaries", "contacts", on_delete: :cascade
  add_foreign_key "vault_entry_contacts", "contacts", on_delete: :cascade
  add_foreign_key "vendor_accounts", "vendors"
  add_foreign_key "vendors", "contacts"
  add_foreign_key "vendors", "users"
end
