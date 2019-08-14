class Document < ApplicationRecord
  belongs_to :collection

  has_many :citation_types, dependent: :destroy
  has_many :fragments, dependent: :destroy

  validates :urn, presence: true, uniqueness: true
  validates :xml, presence: true

  before_save :beautify_xml

  private

  def beautify_xml
    self.xml = Nokogiri::XML(xml).to_xml
  end
end
