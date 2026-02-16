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

ActiveRecord::Schema[8.0].define(version: 2026_02_16_191255) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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

  create_table "comment_kudos", force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.bigint "user_id", null: false
    t.string "kind"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_kudos_on_comment_id"
    t.index ["user_id"], name: "index_comment_kudos_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.bigint "user_id", null: false
    t.integer "photo_index"
    t.text "body"
    t.bigint "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["submission_id"], name: "index_comments_on_submission_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "group_invitations", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "email"
    t.string "token"
    t.bigint "invited_by_id"
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_invitations_on_group_id"
    t.index ["invited_by_id"], name: "index_group_invitations_on_invited_by_id"
  end

  create_table "group_memberships", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "user_id", null: false
    t.integer "role"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_group_memberships_on_group_id"
    t.index ["user_id"], name: "index_group_memberships_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.bigint "owner_id"
    t.boolean "private"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false, null: false
    t.index ["owner_id"], name: "index_groups_on_owner_id"
    t.index ["public"], name: "index_groups_on_public"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "week_id", null: false
    t.bigint "user_id", null: false
    t.text "caption"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "feedback_focus", default: [], null: false, array: true
    t.index ["user_id"], name: "index_submissions_on_user_id"
    t.index ["week_id"], name: "index_submissions_on_week_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name"
    t.string "location"
    t.string "frames_username"
    t.boolean "admin", default: false, null: false
    t.datetime "family_friendly_terms_accepted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "submission_id", null: false
    t.bigint "user_id", null: false
    t.integer "photo_index"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_votes_on_submission_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  create_table "weeks", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.string "title"
    t.date "starts_on"
    t.date "ends_on"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "starts_on", "ends_on"], name: "index_weeks_on_group_id_and_starts_on_and_ends_on", unique: true
    t.index ["group_id"], name: "index_weeks_on_group_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "comment_kudos", "comments"
  add_foreign_key "comment_kudos", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "submissions"
  add_foreign_key "comments", "users", on_delete: :cascade
  add_foreign_key "group_invitations", "groups"
  add_foreign_key "group_invitations", "users", column: "invited_by_id", on_delete: :cascade
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users", on_delete: :cascade
  add_foreign_key "groups", "users", column: "owner_id"
  add_foreign_key "submissions", "users", on_delete: :cascade
  add_foreign_key "submissions", "weeks"
  add_foreign_key "votes", "submissions"
  add_foreign_key "votes", "users", on_delete: :cascade
  add_foreign_key "weeks", "groups"
end
