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

ActiveRecord::Schema[8.0].define(version: 2025_02_17_133331) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "inventory_id", null: false
    t.integer "items_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id"], name: "index_categories_on_inventory_id"
  end

  create_table "inventories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "global_stock_threshold", default: 0, null: false
    t.integer "categories_count", default: 0
    t.integer "items_count", default: 0
    t.integer "inventory_actions_count", default: 0
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_inventories_on_user_id"
  end

  create_table "inventory_actions", force: :cascade do |t|
    t.integer "inventory_id", null: false
    t.integer "item_id", null: false
    t.integer "user_id", null: false
    t.string "action_type", null: false
    t.integer "quantity", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id", "item_id"], name: "index_inventory_actions_on_inventory_and_item"
    t.index ["inventory_id"], name: "index_inventory_actions_on_inventory_id"
    t.index ["item_id"], name: "index_inventory_actions_on_item_id"
    t.index ["user_id"], name: "index_inventory_actions_on_user_id"
  end

  create_table "inventory_invitations", force: :cascade do |t|
    t.integer "inventory_id", null: false
    t.integer "sender_id", null: false
    t.integer "recipient_id", null: false
    t.integer "role", default: 3, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id", "recipient_id"], name: "index_inventory_invitations_on_inventory_id_and_recipient_id"
    t.index ["sender_id"], name: "index_inventory_invitations_on_sender_id"
  end

  create_table "inventory_users", force: :cascade do |t|
    t.integer "inventory_id", null: false
    t.integer "user_id", null: false
    t.integer "role", default: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inventory_id", "user_id"], name: "index_inventory_users_on_inventory_id_and_user_id", unique: true
    t.index ["inventory_id"], name: "index_inventory_users_on_inventory_id"
    t.index ["user_id"], name: "index_inventory_users_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "quantity", null: false
    t.integer "stock_threshold", default: 0, null: false
    t.boolean "low_stock", default: false, null: false
    t.integer "inventory_actions_count", default: 0, null: false
    t.integer "category_id"
    t.integer "inventory_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["inventory_id", "category_id"], name: "index_items_on_inventory_and_category"
    t.index ["inventory_id"], name: "index_items_on_inventory_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "noticed_events", force: :cascade do |t|
    t.string "type"
    t.string "record_type"
    t.bigint "record_id"
    t.json "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notifications_count"
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.string "type"
    t.bigint "event_id", null: false
    t.string "recipient_type", null: false
    t.bigint "recipient_id", null: false
    t.datetime "read_at", precision: nil
    t.datetime "seen_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "status", default: 0, null: false
    t.integer "inventories_count", default: 0
    t.integer "categories_count", default: 0
    t.integer "role", default: 0, null: false
    t.integer "items_count", default: 0, null: false
    t.integer "inventory_actions_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "inventories"
  add_foreign_key "inventories", "users"
  add_foreign_key "inventory_actions", "inventories"
  add_foreign_key "inventory_actions", "items"
  add_foreign_key "inventory_actions", "users"
  add_foreign_key "inventory_invitations", "inventories"
  add_foreign_key "inventory_invitations", "users", column: "recipient_id"
  add_foreign_key "inventory_invitations", "users", column: "sender_id"
  add_foreign_key "inventory_users", "inventories"
  add_foreign_key "inventory_users", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "inventories"
  add_foreign_key "items", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "sessions", "users"
end
