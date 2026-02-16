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

ActiveRecord::Schema[8.0].define(version: 2026_02_03_120000) do
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

  create_table "attendances", force: :cascade do |t|
    t.integer "student_id"
    t.date "date"
    t.integer "status"
    t.text "notes"
    t.integer "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_attendances_on_date"
    t.index ["staff_id"], name: "index_attendances_on_staff_id"
    t.index ["student_id", "date"], name: "index_attendances_on_student_id_and_date", unique: true
    t.index ["student_id"], name: "index_attendances_on_student_id"
  end

  create_table "classrooms", force: :cascade do |t|
    t.string "name"
    t.integer "capacity"
    t.text "description"
    t.integer "teacher_id"
    t.text "schedule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_classrooms_on_teacher_id"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "joined_at"
    t.datetime "left_at"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_conversation_participants_on_active"
    t.index ["conversation_id", "user_id"], name: "index_conversation_participants_on_conversation_id_and_user_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["joined_at"], name: "index_conversation_participants_on_joined_at"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "subject", null: false
    t.text "description"
    t.integer "creator_id"
    t.string "conversation_type", default: "private"
    t.boolean "archived", default: false
    t.datetime "last_activity_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["archived"], name: "index_conversations_on_archived"
    t.index ["conversation_type"], name: "index_conversations_on_conversation_type"
    t.index ["creator_id"], name: "index_conversations_on_creator_id"
    t.index ["last_activity_at"], name: "index_conversations_on_last_activity_at"
  end

  create_table "curriculums", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "classroom_id"
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "discounts", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "fee_category_id"
    t.string "discount_type", null: false
    t.decimal "value", precision: 10, scale: 2, null: false
    t.string "applicable_to", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.boolean "active", default: true
    t.integer "created_by"
    t.integer "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicable_to"], name: "index_discounts_on_applicable_to"
    t.index ["discount_type"], name: "index_discounts_on_discount_type"
    t.index ["fee_category_id"], name: "index_discounts_on_fee_category_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "location"
    t.integer "organizer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organizer_id"], name: "index_events_on_organizer_id"
    t.index ["start_time"], name: "index_events_on_start_time"
  end

  create_table "fee_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "is_discount", default: false
    t.decimal "discount_percentage", precision: 5, scale: 2
    t.boolean "active", default: true
    t.integer "created_by"
    t.integer "updated_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fee_discounts", force: :cascade do |t|
    t.bigint "fee_id", null: false
    t.bigint "discount_id", null: false
    t.decimal "applied_amount", precision: 10, scale: 2, default: "0.0"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discount_id"], name: "index_fee_discounts_on_discount_id"
    t.index ["fee_id", "discount_id"], name: "index_fee_discounts_on_fee_id_and_discount_id", unique: true
    t.index ["fee_id"], name: "index_fee_discounts_on_fee_id"
  end

  create_table "fees", force: :cascade do |t|
    t.integer "student_id"
    t.decimal "amount", precision: 10, scale: 2
    t.date "due_date"
    t.integer "status"
    t.text "description"
    t.string "receipt_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_amount", precision: 10, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 10, scale: 2, default: "0.0"
    t.integer "fee_category_id"
    t.index ["due_date"], name: "index_fees_on_due_date"
    t.index ["fee_category_id"], name: "index_fees_on_fee_category_id"
    t.index ["status"], name: "index_fees_on_status"
    t.index ["student_id"], name: "index_fees_on_student_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "fee_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.text "description"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fee_id"], name: "index_invoice_items_on_fee_id"
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "parent_id", null: false
    t.bigint "created_by_id"
    t.integer "month", null: false
    t.integer "year", null: false
    t.decimal "total_amount", precision: 10, scale: 2, null: false
    t.date "due_date", null: false
    t.string "status", default: "pending"
    t.text "notes"
    t.string "invoice_number"
    t.date "issue_date", default: -> { "CURRENT_DATE" }
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_invoices_on_created_by_id"
    t.index ["due_date"], name: "index_invoices_on_due_date"
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number"
    t.index ["month", "year"], name: "index_invoices_on_month_and_year"
    t.index ["month"], name: "index_invoices_on_month"
    t.index ["parent_id"], name: "index_invoices_on_parent_id"
    t.index ["status"], name: "index_invoices_on_status"
    t.index ["student_id"], name: "index_invoices_on_student_id"
    t.index ["year"], name: "index_invoices_on_year"
  end

  create_table "message_read_receipts", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "user_id", null: false
    t.datetime "read_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "user_id"], name: "index_message_read_receipts_on_message_id_and_user_id", unique: true
    t.index ["message_id"], name: "index_message_read_receipts_on_message_id"
    t.index ["read_at"], name: "index_message_read_receipts_on_read_at"
    t.index ["user_id"], name: "index_message_read_receipts_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.text "content"
    t.string "message_type", default: "text"
    t.boolean "read_status", default: false
    t.datetime "delivered_at"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "created_at"], name: "index_messages_on_conversation_id_and_created_at"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["created_at"], name: "index_messages_on_created_at"
    t.index ["message_type"], name: "index_messages_on_message_type"
    t.index ["read_status"], name: "index_messages_on_read_status"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "title"
    t.text "message"
    t.string "recipient_type"
    t.integer "recipient_id"
    t.integer "sender_id"
    t.datetime "sent_at"
    t.datetime "read_at"
    t.integer "notification_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "link"
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["sender_id"], name: "index_notifications_on_sender_id"
    t.index ["sent_at"], name: "index_notifications_on_sent_at"
  end

  create_table "parent_student_relationships", force: :cascade do |t|
    t.integer "parent_id"
    t.integer "student_id"
    t.integer "relationship_type"
    t.integer "contact_priority"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id", "student_id"], name: "index_parent_student_relationships_on_parent_id_and_student_id", unique: true
    t.index ["parent_id"], name: "index_parent_student_relationships_on_parent_id"
    t.index ["student_id"], name: "index_parent_student_relationships_on_student_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "fee_id", null: false
    t.bigint "student_id"
    t.bigint "created_by_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "payment_method", null: false
    t.string "status", default: "pending"
    t.text "notes"
    t.string "reference_number"
    t.date "payment_date", null: false
    t.string "transaction_id"
    t.json "payment_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_payments_on_created_by_id"
    t.index ["fee_id"], name: "index_payments_on_fee_id"
    t.index ["payment_date"], name: "index_payments_on_payment_date"
    t.index ["payment_method"], name: "index_payments_on_payment_method"
    t.index ["reference_number"], name: "index_payments_on_reference_number"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["student_id"], name: "index_payments_on_student_id"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id"
  end

  create_table "photos", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "uploaded_by_id", null: false
    t.bigint "classroom_id"
    t.string "title", null: false
    t.text "description"
    t.string "category"
    t.boolean "visible_to_parents", default: true
    t.boolean "approved", default: false
    t.datetime "taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approved"], name: "index_photos_on_approved"
    t.index ["category"], name: "index_photos_on_category"
    t.index ["classroom_id", "created_at"], name: "index_photos_on_classroom_id_and_created_at"
    t.index ["classroom_id"], name: "index_photos_on_classroom_id"
    t.index ["student_id", "created_at"], name: "index_photos_on_student_id_and_created_at"
    t.index ["student_id"], name: "index_photos_on_student_id"
    t.index ["taken_at"], name: "index_photos_on_taken_at"
    t.index ["title"], name: "index_photos_on_title"
    t.index ["uploaded_by_id", "created_at"], name: "index_photos_on_uploaded_by_id_and_created_at"
    t.index ["uploaded_by_id"], name: "index_photos_on_uploaded_by_id"
    t.index ["visible_to_parents"], name: "index_photos_on_visible_to_parents"
  end

  create_table "resources", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "category"
    t.integer "classroom_id"
    t.integer "user_id"
    t.string "subject"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.date "enrollment_date"
    t.integer "status"
    t.integer "gender"
    t.string "emergency_contact_name"
    t.string "emergency_contact_phone"
    t.text "medical_information"
    t.integer "parent_id"
    t.integer "classroom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["classroom_id"], name: "index_students_on_classroom_id"
    t.index ["parent_id"], name: "index_students_on_parent_id"
    t.index ["status"], name: "index_students_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "encrypted_password"
    t.integer "role"
    t.integer "status"
    t.string "phone"
    t.date "date_of_birth"
    t.text "address"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "approved", default: false
    t.datetime "approved_at"
    t.string "verification_code"
    t.integer "role_request"
    t.string "otp_secret"
    t.integer "otp_attempts_count", default: 0
    t.datetime "otp_last_attempt_at"
    t.datetime "otp_expires_at"
    t.datetime "otp_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "students"
  add_foreign_key "attendances", "users", column: "staff_id"
  add_foreign_key "classrooms", "users", column: "teacher_id"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "events", "users", column: "organizer_id"
  add_foreign_key "fee_discounts", "discounts"
  add_foreign_key "fee_discounts", "fees"
  add_foreign_key "fees", "students"
  add_foreign_key "invoice_items", "fees"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "students"
  add_foreign_key "invoices", "users", column: "created_by_id"
  add_foreign_key "invoices", "users", column: "parent_id"
  add_foreign_key "message_read_receipts", "messages"
  add_foreign_key "message_read_receipts", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "notifications", "users", column: "sender_id"
  add_foreign_key "parent_student_relationships", "students"
  add_foreign_key "parent_student_relationships", "users", column: "parent_id"
  add_foreign_key "payments", "fees"
  add_foreign_key "payments", "students"
  add_foreign_key "payments", "users", column: "created_by_id"
  add_foreign_key "photos", "classrooms"
  add_foreign_key "photos", "students"
  add_foreign_key "photos", "users", column: "uploaded_by_id"
  add_foreign_key "students", "classrooms"
  add_foreign_key "students", "users", column: "parent_id"
end
