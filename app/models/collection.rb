class Collection < ApplicationRecord
  belongs_to :parent, class_name: 'Collection', optional: true

  has_many :children, class_name: 'Collection', dependent: :destroy, foreign_key: :parent_id, inverse_of: :parent
  has_many :documents, dependent: :destroy
  has_many :collection_titles, dependent: :destroy

  validates :urn, presence: true, uniqueness: true
  validates :title, presence: true
end
