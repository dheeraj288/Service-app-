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

ActiveRecord::Schema[7.1].define(version: 2025_07_21_155342) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "buildings", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "elevators", force: :cascade do |t|
    t.string "identifier"
    t.string "elevator_type"
    t.integer "status", default: 0
    t.bigint "building_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_elevators_on_building_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "time_ticket_id", null: false
    t.string "invoice_number"
    t.decimal "total_amount"
    t.string "pdf_url"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_ticket_id"], name: "index_invoices_on_time_ticket_id"
  end

  create_table "preventive_maintenances", force: :cascade do |t|
    t.bigint "shop_id", null: false
    t.integer "customer_id"
    t.integer "technician_id"
    t.date "schedule_date"
    t.string "frequency"
    t.string "status"
    t.date "next_run_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_preventive_maintenances_on_shop_id"
  end

  create_table "quickbooks_tokens", force: :cascade do |t|
    t.integer "shop_id"
    t.string "access_token"
    t.string "refresh_token"
    t.string "realm_id"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "customer_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.bigint "time_ticket_id", null: false
    t.integer "shop_admin_id"
    t.text "description"
    t.decimal "amount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["time_ticket_id"], name: "index_quotes_on_time_ticket_id"
  end

  create_table "scheduled_repairs", force: :cascade do |t|
    t.bigint "shop_id"
    t.bigint "building_id"
    t.bigint "elevator_id"
    t.integer "customer_id"
    t.integer "technician_id"
    t.text "description"
    t.datetime "scheduled_for"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_id"], name: "index_scheduled_repairs_on_building_id"
    t.index ["elevator_id"], name: "index_scheduled_repairs_on_elevator_id"
    t.index ["shop_id"], name: "index_scheduled_repairs_on_shop_id"
  end

  create_table "service_requests", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "status"
    t.datetime "eta"
    t.datetime "assigned_at"
    t.integer "customer_id"
    t.integer "technician_id"
    t.bigint "shop_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shop_id"], name: "index_service_requests_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_shops_on_code", unique: true
  end

  create_table "time_tickets", force: :cascade do |t|
    t.bigint "service_request_id", null: false
    t.integer "technician_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "total_hours"
    t.string "status"
    t.text "notes"
    t.datetime "approved_at"
    t.integer "approved_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "rejected_at"
    t.integer "rejected_by"
    t.text "rejection_reason"
    t.index ["service_request_id"], name: "index_time_tickets_on_service_request_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "address"
    t.string "role"
    t.string "profile_image_url"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shop_id"
  end

  add_foreign_key "elevators", "buildings"
  add_foreign_key "invoices", "time_tickets"
  add_foreign_key "preventive_maintenances", "shops"
  add_foreign_key "quotes", "time_tickets"
  add_foreign_key "scheduled_repairs", "buildings"
  add_foreign_key "scheduled_repairs", "elevators"
  add_foreign_key "scheduled_repairs", "shops"
  add_foreign_key "service_requests", "shops"
  add_foreign_key "time_tickets", "service_requests"
end
