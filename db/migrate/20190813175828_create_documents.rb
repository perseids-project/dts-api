class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.string :urn, null: false

      t.references :collection, null: false, foreign_key: true, index: true

      t.xml :xml, null: false

      t.timestamps null: false
    end

    add_index :documents, :uuid, unique: true
    add_index :documents, :urn, unique: true
  end
end
