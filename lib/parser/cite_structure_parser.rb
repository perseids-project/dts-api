class CiteStructureParser
  def self.cite_structure(file)
    new(file).cite_structure
  end

  def initialize(file)
    @xml = Nokogiri::XML(file)
  end

  def cite_structure
    xml.xpath(
      '/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:refsDecl/tei:cRefPattern',
      tei: 'http://www.tei-c.org/ns/1.0',
    ).map { |pattern| pattern['n'] }.reverse
  end

  private

  attr_reader :xml, :collection
end
