class CollectionTitle < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :collection

  validates :title, presence: true
  validates :language, presence: true, language: true, uniqueness: { scope: :collection_id }

  canonicalize :language
end
