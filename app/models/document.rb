class Document < ApplicationRecord
  belongs_to :collection

  has_many :fragments, dependent: :destroy

  validates :urn, presence: true, uniqueness: true
  validates :xml, presence: true
end
