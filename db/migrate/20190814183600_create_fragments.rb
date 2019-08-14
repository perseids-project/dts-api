class CreateFragments < ActiveRecord::Migration[6.0]
  def change
    create_table :fragments do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false
      t.string :ref, null: false

      t.references :document, null: false, foreign_key: true, index: true
      t.references :parent, foreign_key: { to_table: :fragments }, index: true

      t.xml :xml, null: false
      t.integer :level, null: false
      t.integer :rank, null: false

      t.timestamps null: false
    end

    add_index :fragments, :uuid, unique: true
    add_index :fragments, [:document_id, :ref], unique: true
    add_index :fragments, [:document_id, :level, :rank], unique: true
  end
end
