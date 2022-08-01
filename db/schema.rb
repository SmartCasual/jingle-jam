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

ActiveRecord::Schema[7.0].define(version: 2022_07_30_220559) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email_address", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "otp_secret"
    t.datetime "last_otp_at"
    t.boolean "data_entry", default: false, null: false
    t.boolean "support", default: false, null: false
    t.boolean "manages_users", default: false, null: false
    t.boolean "full_access", default: false, null: false
    t.string "name"
    t.index ["email_address"], name: "index_admin_users_on_email_address", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "bundle_tier_games", force: :cascade do |t|
    t.bigint "bundle_tier_id", null: false
    t.bigint "game_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_tier_id"], name: "index_bundle_tier_games_on_bundle_tier_id"
    t.index ["game_id"], name: "index_bundle_tier_games_on_game_id"
  end

  create_table "bundle_tiers", force: :cascade do |t|
    t.integer "price_decimals", default: 0, null: false
    t.string "price_currency", default: "GBP", null: false
    t.string "name"
    t.bigint "bundle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.index ["bundle_id"], name: "index_bundle_tiers_on_bundle_id"
  end

  create_table "bundles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state", default: "draft", null: false
    t.bigint "fundraiser_id", null: false
    t.index ["fundraiser_id"], name: "index_bundles_on_fundraiser_id"
    t.index ["name", "fundraiser_id"], name: "index_bundles_on_name_and_fundraiser_id", unique: true
  end

  create_table "charities", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_charities_on_name"
  end

  create_table "charity_fundraisers", force: :cascade do |t|
    t.bigint "charity_id"
    t.bigint "fundraiser_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charity_id"], name: "index_charity_fundraisers_on_charity_id"
    t.index ["fundraiser_id"], name: "index_charity_fundraisers_on_fundraiser_id"
  end

  create_table "charity_splits", force: :cascade do |t|
    t.bigint "donation_id"
    t.bigint "charity_id"
    t.string "amount_currency", default: "GBP", null: false
    t.integer "amount_decimals", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["charity_id"], name: "index_charity_splits_on_charity_id"
    t.index ["donation_id"], name: "index_charity_splits_on_donation_id"
  end

  create_table "curated_streamer_administrators", force: :cascade do |t|
    t.bigint "curated_streamer_id", null: false
    t.bigint "donator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["curated_streamer_id", "donator_id"], name: "ref_index", unique: true
    t.index ["curated_streamer_id"], name: "index_curated_streamer_administrators_on_curated_streamer_id"
    t.index ["donator_id"], name: "index_curated_streamer_administrators_on_donator_id"
  end

  create_table "curated_streamers", force: :cascade do |t|
    t.string "twitch_username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["twitch_username"], name: "index_curated_streamers_on_twitch_username"
  end

  create_table "donations", force: :cascade do |t|
    t.integer "amount_decimals", default: 0, null: false
    t.string "amount_currency", default: "GBP", null: false
    t.string "message"
    t.bigint "donator_id", null: false
    t.bigint "donated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "aasm_state", default: "pending", null: false
    t.bigint "curated_streamer_id"
    t.string "stripe_payment_intent_id"
    t.string "paypal_order_id"
    t.string "donator_name"
    t.bigint "fundraiser_id"
    t.datetime "paid_at"
    t.index ["curated_streamer_id"], name: "index_donations_on_curated_streamer_id"
    t.index ["donated_by_id"], name: "index_donations_on_donated_by_id"
    t.index ["donator_id"], name: "index_donations_on_donator_id"
    t.index ["fundraiser_id"], name: "index_donations_on_fundraiser_id"
    t.index ["paid_at"], name: "index_donations_on_paid_at"
    t.check_constraint "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"
  end

  create_table "donator_bundle_tiers", force: :cascade do |t|
    t.bigint "donator_bundle_id", null: false
    t.bigint "bundle_tier_id", null: false
    t.boolean "unlocked", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bundle_tier_id"], name: "index_donator_bundle_tiers_on_bundle_tier_id"
    t.index ["donator_bundle_id"], name: "index_donator_bundle_tiers_on_donator_bundle_id"
  end

  create_table "donator_bundles", force: :cascade do |t|
    t.bigint "donator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "bundle_id", null: false
    t.index ["bundle_id"], name: "index_donator_bundles_on_bundle_id"
    t.index ["donator_id"], name: "index_donator_bundles_on_donator_id"
  end

  create_table "donators", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_address"
    t.string "chosen_name"
    t.string "stripe_customer_id"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "twitch_id"
    t.index ["confirmation_token"], name: "index_donators_on_confirmation_token", unique: true
    t.index ["email_address"], name: "index_donators_on_email_address", unique: true, where: "(confirmed_at IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_donators_on_reset_password_token", unique: true
    t.index ["twitch_id"], name: "index_donators_on_twitch_id", unique: true
    t.index ["unlock_token"], name: "index_donators_on_unlock_token", unique: true
  end

  create_table "fundraisers", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "short_url"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "overpayment_mode", default: "pro_bono", null: false
    t.string "state", default: "inactive", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "main_currency", default: "GBP", null: false
  end

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
  end

  create_table "keys", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "donator_bundle_tier_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "code_ciphertext"
    t.text "encrypted_kms_key"
    t.string "code_bidx"
    t.bigint "fundraiser_id"
    t.index ["code_bidx"], name: "index_keys_on_code_bidx", unique: true
    t.index ["donator_bundle_tier_id", "game_id"], name: "index_keys_on_donator_bundle_tier_id_and_game_id", unique: true
    t.index ["donator_bundle_tier_id"], name: "index_keys_on_donator_bundle_tier_id"
    t.index ["fundraiser_id"], name: "index_keys_on_fundraiser_id"
    t.index ["game_id"], name: "index_keys_on_game_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "amount_currency", default: "GBP", null: false
    t.integer "amount_decimals", default: 0, null: false
    t.bigint "donation_id"
    t.string "stripe_payment_intent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "paypal_order_id"
    t.index ["donation_id"], name: "index_payments_on_donation_id"
    t.check_constraint "num_nonnulls(stripe_payment_intent_id, paypal_order_id) > 0"
  end

  add_foreign_key "bundle_tiers", "bundles"
  add_foreign_key "donator_bundle_tiers", "bundle_tiers"
  add_foreign_key "donator_bundle_tiers", "donator_bundles"
end
