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

ActiveRecord::Schema[7.1].define(version: 2026_04_01_232422) do
  create_table "audit_trails", force: :cascade do |t|
    t.string "action"
    t.integer "user_id", null: false
    t.integer "batch_id", null: false
    t.integer "tenant_id", null: false
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_audit_trails_on_batch_id"
    t.index ["tenant_id"], name: "index_audit_trails_on_tenant_id"
    t.index ["user_id"], name: "index_audit_trails_on_user_id"
  end

  create_table "batches", force: :cascade do |t|
    t.string "batch_id"
    t.string "product"
    t.string "status"
    t.string "temp"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tenant_id", null: false
    t.index ["tenant_id"], name: "index_batches_on_tenant_id"
  end

  create_table "event_logs", force: :cascade do |t|
    t.string "action"
    t.integer "user_id", null: false
    t.integer "batch_id", null: false
    t.integer "tenant_id", null: false
    t.text "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_event_logs_on_batch_id"
    t.index ["tenant_id"], name: "index_event_logs_on_tenant_id"
    t.index ["user_id"], name: "index_event_logs_on_user_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.string "shipment_id"
    t.string "status"
    t.text "biologics"
    t.string "origin"
    t.string "destination"
    t.string "temperature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tenants", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "plan"
    t.string "stripe_id"
    t.index ["stripe_id"], name: "index_tenants_on_stripe_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_otp_secret"
    t.text "otp_backup_codes"
    t.integer "consumed_timestep"
    t.string "name"
    t.datetime "current_sign_in_at"
    t.integer "sign_in_count"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "last_sign_in_at"
    t.integer "failed_attempts"
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "otp_required_for_login", default: true, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "audit_trails", "batches"
  add_foreign_key "audit_trails", "tenants"
  add_foreign_key "audit_trails", "users"
  add_foreign_key "batches", "tenants"
  add_foreign_key "event_logs", "batches"
  add_foreign_key "event_logs", "tenants"
  add_foreign_key "event_logs", "users"
end
