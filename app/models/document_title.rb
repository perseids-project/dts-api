class DocumentTitle < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :document

  validates :title, presence: true
  validates :language, presence: true, language: true

  canonicalize :language
end
