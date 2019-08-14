class CitationType < ApplicationRecord
  belongs_to :document

  validates :level, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :document_id }
  validates :citation_type, presence: true
end
