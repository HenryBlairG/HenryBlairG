# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_02_214230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "checking_accounts", force: :cascade do |t|
    t.string "currency"
    t.integer "liquid_balance", default: 0
    t.integer "illiquid_balance", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_checking_accounts_on_user_id"
  end

  create_table "credit_accounts", force: :cascade do |t|
    t.string "currency"
    t.integer "liquid_balance", default: 0
    t.integer "illiquid_balance", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.integer "credit_limit", default: -1000000, null: false
    t.index ["user_id"], name: "index_credit_accounts_on_user_id"
  end

  create_table "debit_accounts", force: :cascade do |t|
    t.string "currency"
    t.integer "liquid_balance", default: 0
    t.integer "illiquid_balance", default: 0
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_debit_accounts_on_user_id"
  end

  create_table "installments", force: :cascade do |t|
    t.integer "place"
    t.integer "total_places"
    t.integer "unit_amount", null: false
    t.integer "total_amount", null: false
    t.boolean "liq_status", default: false, null: false
    t.datetime "liq_date"
    t.bigint "transaction_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["transaction_id"], name: "index_installments_on_transaction_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "currency"
    t.integer "origin_id"
    t.string "description"
    t.integer "amount", null: false
    t.bigint "category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "origin_type"
    t.integer "installments_qty", default: 1
    t.boolean "status", default: false
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["origin_type", "origin_id"], name: "index_transactions_on_origin_type_and_origin_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.boolean "admin", default: false
    t.boolean "suspended", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "checking_accounts", "users"
  add_foreign_key "credit_accounts", "users"
  add_foreign_key "debit_accounts", "users"
  add_foreign_key "installments", "transactions"
  add_foreign_key "transactions", "categories"
end
