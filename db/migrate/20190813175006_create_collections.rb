class CreateCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :collections do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.string :urn, null: false

      t.references :parent, foreign_key: { to_table: :collections }, index: true

      t.string :title, null: false
      t.string :description
      t.string :language
      t.integer :display_type, null: false, default: 0
      t.integer :children_count, null: false, default: 0

      t.timestamps null: false
    end

    add_index :collections, :uuid, unique: true
    add_index :collections, :urn, unique: true
  end
end
