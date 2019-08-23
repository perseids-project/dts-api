class Document < ApplicationRecord
  include BeautifyXml
  include CanonicalizeLanguage

  belongs_to :collection

  has_many :citation_types, dependent: :destroy
  has_many :fragments, dependent: :destroy
  has_many :document_titles, dependent: :destroy
  has_many :document_descriptions, dependent: :destroy

  validates :urn, presence: true, uniqueness: true
  validates :xml, presence: true
  validates :title, presence: true
  validates :language, presence: true, language: true

  beautify :xml
  canonicalize :language
end
