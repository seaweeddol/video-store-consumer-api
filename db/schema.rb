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

ActiveRecord::Schema.define(version: 2018_06_18_042754) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.datetime "registered_at"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "postal_code"
    t.string "phone"
    t.float "account_credit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "movies", force: :cascade do |t|
    t.string "title"
    t.text "overview"
    t.date "release_date"
    t.integer "inventory"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
    t.integer "external_id"
  end

  create_table "rentals", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "movie_id"
    t.date "checkout_date"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "returned"
    t.index ["customer_id"], name: "index_rentals_on_customer_id"
    t.index ["movie_id"], name: "index_rentals_on_movie_id"
  end

end
