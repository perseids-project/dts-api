class CiteStructureParser
  def self.cite_structure(xml)
    new(xml).cite_structure
  end

  def initialize(xml)
    @xml = xml
  end

  def cite_structure
    ref_pattern.each_with_index.map { |n, i| n.presence || unknown(i) }
  end

  private

  def ref_pattern
    xml.xpath(
      '/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:refsDecl/tei:cRefPattern',
      tei: 'http://www.tei-c.org/ns/1.0',
    ).map { |pattern| pattern['n'] }.reverse
  end

  def unknown(ref)
    case ref
    when 0 then 'book'
    when 1 then 'chapter'
    when 2 then 'section'
    when 3 then 'line'
    else "ref#{ref}"
    end
  end

  attr_reader :xml
end
