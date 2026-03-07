# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_07_225559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_admins_on_confirmation_token", unique: true
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "datapass_employee_details", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "birth_date"
    t.datetime "created_at", null: false
    t.string "crew_trainer_trained"
    t.date "crew_trainer_trained_date"
    t.date "current_role_promotion_date"
    t.string "eid"
    t.string "email"
    t.string "employee_status"
    t.string "first_name"
    t.date "first_punch_date"
    t.string "geid"
    t.string "gerid"
    t.date "graduation_date"
    t.string "hu_graduate"
    t.string "jtc"
    t.string "last_name"
    t.uuid "location_id", null: false
    t.string "nick_name"
    t.uuid "organization_id", null: false
    t.date "organization_start_date"
    t.date "organization_termination_date"
    t.date "orientation_date"
    t.string "payroll_id"
    t.string "primary_job_title"
    t.string "primary_phone"
    t.string "primary_store_nsn"
    t.string "reason"
    t.string "secondary_job_title"
    t.string "secondary_jtc"
    t.jsonb "shared_stores"
    t.string "shift_manager_trained"
    t.date "shift_manager_trained_date"
    t.float "trailing_4_weeks_actual_hours_worked"
    t.float "trailing_7_days_actual_hours_worked"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_datapass_employee_details_on_location_id"
    t.index ["organization_id"], name: "index_datapass_employee_details_on_organization_id"
  end

  create_table "datapass_identifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.date "birth_day"
    t.datetime "created_at", null: false
    t.string "email_address"
    t.jsonb "emp_job_title_history"
    t.string "ethnicity"
    t.string "first_name"
    t.string "geid"
    t.string "gender"
    t.string "home_store_nsn"
    t.string "last_initial"
    t.uuid "location_id", null: false
    t.string "nickname"
    t.uuid "organization_id", null: false
    t.string "primary_time_card"
    t.string "secondary_time_card"
    t.string "ssn"
    t.string "unique_id"
    t.datetime "updated_at", null: false
    t.string "zip_code"
    t.index ["location_id"], name: "index_datapass_identifications_on_location_id"
    t.index ["organization_id"], name: "index_datapass_identifications_on_organization_id"
  end

  create_table "datapass_idmgmts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "first_name"
    t.string "geid"
    t.string "gerid"
    t.string "glin"
    t.jsonb "jtcs"
    t.string "last_name"
    t.uuid "location_id", null: false
    t.jsonb "matching_criteria"
    t.string "middle_initial"
    t.date "modified"
    t.string "nsn"
    t.uuid "organization_id", null: false
    t.date "organization_start_date"
    t.date "organization_termination_date"
    t.string "payroll_id"
    t.jsonb "phones"
    t.jsonb "shares"
    t.string "termination_code"
    t.datetime "updated_at", null: false
    t.index ["location_id"], name: "index_datapass_idmgmts_on_location_id"
    t.index ["organization_id"], name: "index_datapass_idmgmts_on_organization_id"
  end

  create_table "hr_ssns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "geid", null: false
    t.uuid "organization_id"
    t.string "ssn", null: false
    t.datetime "updated_at", null: false
    t.index ["geid"], name: "index_hr_ssns_on_geid"
  end

  create_table "inbound_webhooks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
  end

  create_table "locations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "headset_count", null: false
    t.integer "ipad_count"
    t.string "location_type", default: "Traditional"
    t.string "name", null: false
    t.string "number", null: false
    t.uuid "organization_id"
    t.string "phone", null: false
    t.integer "safe_count", null: false
    t.string "state", null: false
    t.string "street", null: false
    t.datetime "updated_at", null: false
    t.string "zip", null: false
    t.index ["email"], name: "index_locations_on_email", unique: true
    t.index ["phone"], name: "index_locations_on_phone", unique: true
  end

  create_table "locations_users", id: false, force: :cascade do |t|
    t.uuid "location_id"
    t.uuid "user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "eid", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.string "primary_eid"
    t.boolean "primary_operator", default: true, null: false
    t.string "state", null: false
    t.string "street", null: false
    t.datetime "updated_at", null: false
    t.string "zip", null: false
    t.index ["eid"], name: "index_organizations_on_eid"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.uuid "location_id"
    t.datetime "locked_at"
    t.uuid "organization_id"
    t.string "phone_number"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "datapass_employee_details", "locations"
  add_foreign_key "datapass_employee_details", "organizations"
  add_foreign_key "datapass_identifications", "locations"
  add_foreign_key "datapass_identifications", "organizations"
  add_foreign_key "datapass_idmgmts", "locations"
  add_foreign_key "datapass_idmgmts", "organizations"
  add_foreign_key "hr_ssns", "organizations"
  add_foreign_key "locations", "organizations"
  add_foreign_key "users", "locations"
  add_foreign_key "users", "organizations"
end
