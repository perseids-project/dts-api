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

ActiveRecord::Schema.define(version: 2019_08_16_174624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "collection_descriptions", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "collection_id", null: false
    t.string "description", null: false
    t.string "language", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collection_id"], name: "index_collection_descriptions_on_collection_id"
    t.index ["uuid"], name: "index_collection_descriptions_on_uuid", unique: true
  end

  create_table "collection_titles", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.bigint "collection_id", null: false
    t.string "title", null: false
    t.string "language", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collection_id"], name: "index_collection_titles_on_collection_id"
    t.index ["uuid"], name: "index_collection_titles_on_uuid", unique: true
  end

  create_table "collections", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "urn", null: false
    t.bigint "parent_id"
    t.string "title", null: false
    t.string "description"
    t.string "language"
    t.integer "display_type", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.string "cite_structure", array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["parent_id"], name: "index_collections_on_parent_id"
    t.index ["urn"], name: "index_collections_on_urn", unique: true
    t.index ["uuid"], name: "index_collections_on_uuid", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "urn", null: false
    t.bigint "collection_id", null: false
    t.text "xml", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["collection_id"], name: "index_documents_on_collection_id"
    t.index ["urn"], name: "index_documents_on_urn", unique: true
    t.index ["uuid"], name: "index_documents_on_uuid", unique: true
  end

  create_table "fragments", force: :cascade do |t|
    t.uuid "uuid", default: -> { "gen_random_uuid()" }, null: false
    t.string "ref", null: false
    t.bigint "document_id", null: false
    t.bigint "parent_id"
    t.text "xml", null: false
    t.integer "level", null: false
    t.integer "rank", null: false
    t.integer "descendent_rank", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_id", "rank"], name: "index_fragments_on_document_id_and_rank", unique: true
    t.index ["document_id", "ref"], name: "index_fragments_on_document_id_and_ref", unique: true
    t.index ["document_id"], name: "index_fragments_on_document_id"
    t.index ["parent_id"], name: "index_fragments_on_parent_id"
    t.index ["uuid"], name: "index_fragments_on_uuid", unique: true
  end

  add_foreign_key "collection_descriptions", "collections"
  add_foreign_key "collection_titles", "collections"
  add_foreign_key "collections", "collections", column: "parent_id"
  add_foreign_key "documents", "collections"
  add_foreign_key "fragments", "documents"
  add_foreign_key "fragments", "fragments", column: "parent_id"
end
