class CollectionTitle < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :collection

  validates :title, presence: true
  validates :language, presence: true, language: true

  canonicalize :language
end
