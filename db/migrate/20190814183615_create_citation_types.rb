class CreateCitationTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :citation_types do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false

      t.references :document, null: false, foreign_key: true, index: true

      t.integer :level, null: false
      t.string :citation_type, null: false

      t.timestamps null: false
    end

    add_index :citation_types, :uuid, unique: true
    add_index :citation_types, [:document_id, :level], unique: true
  end
end
