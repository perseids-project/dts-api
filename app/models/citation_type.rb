class CitationType < ApplicationRecord
  belongs_to :collection

  validates :level, presence: true, numericality: { only_integer: true }, uniqueness: { scope: :collection_id }
  validates :citation_type, presence: true
end
