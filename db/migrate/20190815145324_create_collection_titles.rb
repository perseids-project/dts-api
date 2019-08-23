class CreateCollectionTitles < ActiveRecord::Migration[6.0]
  def change
    create_table :collection_titles do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false

      t.references :collection, null: false, foreign_key: true, index: true

      t.string :title, null: false
      t.string :language, null: false

      t.timestamps null: false
    end

    add_index :collection_titles, :uuid, unique: true
  end
end
