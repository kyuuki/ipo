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

ActiveRecord::Schema.define(version: 20180717083644) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "stock_company_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_company_id"], name: "index_accounts_on_stock_company_id"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "applications", force: :cascade do |t|
    t.bigint "ipo_company_id"
    t.bigint "account_id"
    t.integer "amount"
    t.boolean "applied"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_applications_on_account_id"
    t.index ["ipo_company_id"], name: "index_applications_on_ipo_company_id"
  end

  create_table "handlings", force: :cascade do |t|
    t.bigint "ipo_company_id"
    t.bigint "stock_company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ipo_company_id"], name: "index_handlings_on_ipo_company_id"
    t.index ["stock_company_id"], name: "index_handlings_on_stock_company_id"
  end

  create_table "ipo_companies", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "rank"
    t.integer "price"
    t.date "listed_at"
    t.date "apply_from"
    t.date "apply_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "drawing_at"
  end

  create_table "stock_companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.string "regexp"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "accounts", "stock_companies"
  add_foreign_key "accounts", "users"
  add_foreign_key "applications", "accounts"
  add_foreign_key "applications", "ipo_companies"
  add_foreign_key "handlings", "ipo_companies"
  add_foreign_key "handlings", "stock_companies"
end
