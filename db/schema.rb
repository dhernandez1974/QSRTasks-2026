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

ActiveRecord::Schema[8.1].define(version: 2026_03_07_174801) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
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

  create_table "hr_ssns", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "eid", null: false
    t.bigint "organization_id", null: false
    t.string "ssn", null: false
    t.datetime "updated_at", null: false
    t.index ["eid"], name: "index_hr_ssns_on_eid"
    t.index ["organization_id"], name: "index_hr_ssns_on_organization_id"
  end

  create_table "inbound_webhooks", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "city", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "headset_count", null: false
    t.integer "ipad_count"
    t.string "location_type", default: "Traditional"
    t.string "name", null: false
    t.string "number", null: false
    t.bigint "organization_id", null: false
    t.string "phone", null: false
    t.integer "safe_count", null: false
    t.string "state", null: false
    t.string "street", null: false
    t.datetime "updated_at", null: false
    t.string "zip", null: false
    t.index ["organization_id"], name: "index_locations_on_organization_id"
  end

  create_table "locations_users", id: false, force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "user_id", null: false
  end

  create_table "organizations", force: :cascade do |t|
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

  create_table "users", force: :cascade do |t|
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
    t.bigint "location_id"
    t.datetime "locked_at"
    t.bigint "organization_id"
    t.string "phone_number"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["location_id"], name: "index_users_on_location_id"
    t.index ["organization_id"], name: "index_users_on_organization_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "hr_ssns", "organizations"
  add_foreign_key "locations", "organizations"
  add_foreign_key "users", "locations"
  add_foreign_key "users", "organizations"
end
