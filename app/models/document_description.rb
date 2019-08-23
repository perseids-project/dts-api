class DocumentDescription < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :document

  validates :description, presence: true
  validates :language, presence: true, language: true

  canonicalize :language
end
