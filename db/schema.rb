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

ActiveRecord::Schema[7.1].define(version: 2025_03_13_202815) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "matches", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.bigint "matched_pet_id", null: false
    t.string "status"
    t.datetime "matched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matched_pet_id"], name: "index_matches_on_matched_pet_id"
    t.index ["pet_id"], name: "index_matches_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "species"
    t.string "breed"
    t.integer "age"
    t.string "gender"
    t.text "bio"
    t.text "personality_traits"
    t.string "temperament"
    t.string "size"
    t.string "age_group"
    t.boolean "is_vaccinated"
    t.boolean "is_neutered"
    t.text "medical_conditions"
    t.boolean "is_available_for_breeding"
    t.text "breeding_history"
    t.boolean "registered_pedigree"
    t.string "looking_for"
    t.string "preferred_species"
    t.string "preferred_size"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "matches", "pets"
  add_foreign_key "matches", "pets", column: "matched_pet_id"
  add_foreign_key "pets", "users"
end
