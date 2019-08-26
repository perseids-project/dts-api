class Collection < ApplicationRecord
  include CanonicalizeLanguage

  belongs_to :parent, class_name: 'Collection', optional: true, counter_cache: :children_count

  has_many :children, class_name: 'Collection', dependent: :destroy, foreign_key: :parent_id, inverse_of: :parent
  has_many :citation_types, dependent: :destroy
  has_many :collection_descriptions, dependent: :destroy
  has_many :collection_titles, dependent: :destroy

  has_one :document, dependent: :destroy

  validates :urn, presence: true, uniqueness: true
  validates :title, presence: true
  validates :language, language: true

  enum display_type: [:collection, :resource]

  canonicalize :language
end
