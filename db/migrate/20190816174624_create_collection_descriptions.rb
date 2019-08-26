class CreateCollectionDescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :collection_descriptions do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false

      t.references :collection, null: false, foreign_key: true, index: true

      t.string :description, null: false
      t.string :language, null: false

      t.timestamps null: false
    end

    add_index :collection_descriptions, :uuid, unique: true
  end
end
