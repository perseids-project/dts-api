class CollectionDescription < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :collection

  validates :description, presence: true
  validates :language, presence: true, language: true

  canonicalize :language
end
