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

ActiveRecord::Schema.define(version: 2021_03_21_174458) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bundle_definition_game_entries", force: :cascade do |t|
    t.bigint "bundle_definition_id", null: false
    t.bigint "game_id", null: false
    t.integer "price_decimals"
    t.string "price_currency"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bundle_definition_id"], name: "index_bundle_definition_game_entries_on_bundle_definition_id"
    t.index ["game_id"], name: "index_bundle_definition_game_entries_on_game_id"
  end

  create_table "bundle_definitions", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price_decimals", default: 0, null: false
    t.string "price_currency", default: "GBP", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bundles", force: :cascade do |t|
    t.bigint "donator_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "bundle_definition_id", null: false
    t.index ["bundle_definition_id"], name: "index_bundles_on_bundle_definition_id"
    t.index ["donator_id"], name: "index_bundles_on_donator_id"
  end

  create_table "donations", force: :cascade do |t|
    t.integer "amount_decimals", default: 0, null: false
    t.string "amount_currency", default: "GBP", null: false
    t.string "message"
    t.bigint "donator_id", null: false
    t.bigint "donated_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "aasm_state", default: "pending", null: false
    t.string "stripe_checkout_session_id"
    t.index ["donated_by_id"], name: "index_donations_on_donated_by_id"
    t.index ["donator_id"], name: "index_donations_on_donator_id"
  end

  create_table "donators", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email_address"
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "description"
  end

  create_table "keys", force: :cascade do |t|
    t.string "code", null: false
    t.bigint "game_id", null: false
    t.bigint "bundle_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["bundle_id", "game_id"], name: "index_keys_on_bundle_id_and_game_id", unique: true
    t.index ["bundle_id"], name: "index_keys_on_bundle_id"
    t.index ["game_id"], name: "index_keys_on_game_id"
  end

end
