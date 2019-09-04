class Fragment < ApplicationRecord
  belongs_to :document
  belongs_to :parent, class_name: 'Fragment', optional: true

  has_many :children, class_name: 'Fragment', dependent: :destroy, foreign_key: :parent_id, inverse_of: :parent

  validates :ref, presence: true, uniqueness: { scope: :document_id }
  validates :xml, presence: true
  validates :level, presence: true, numericality: { only_integer: true }
  validates :rank,
    presence: true,
    numericality: { only_integer: true },
    uniqueness: { scope: [:document_id, :parent_id, :ref] }
end
