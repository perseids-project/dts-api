class CreateDocumentDescriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :document_descriptions do |t|
      t.uuid :uuid, default: 'gen_random_uuid()', null: false

      t.references :document, null: false, foreign_key: true, index: true

      t.string :description, null: false
      t.string :language, null: false

      t.timestamps null: false
    end

    add_index :document_descriptions, :uuid, unique: true
    add_index :document_descriptions, [:document_id, :language], unique: true
  end
end
