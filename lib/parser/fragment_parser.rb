class FragmentParser
  def self.build(document, xml)
    new(document, xml).build
  end

  def initialize(document, xml)
    @document = document
    @xml = xml
  end

  def build
    if xml.errors.present?
      fragments = []
    else
      begin
        fragments = build_fragments(1, nil, { "='$1'" => '' }, replacement_patterns_from_xml)
      rescue Nokogiri::XML::XPath::SyntaxError
        fragments = []
      end
    end

    document.fragments = fragments
  end

  private

  def replacement_patterns_from_xml
    xml.xpath(
      '/tei:TEI/tei:teiHeader/tei:encodingDesc/tei:refsDecl/tei:cRefPattern',
      tei: 'http://www.tei-c.org/ns/1.0',
    ).map { |pattern| xpath_from_pattern(pattern) }.reverse
  end

  def build_fragments(level, ref, gsubs, replacement_patterns)
    return [] if replacement_patterns.empty?

    replacement_pattern, *other_patterns = replacement_patterns

    xml.xpath(
      gsub_hash(replacement_pattern, gsubs),
      tei: 'http://www.tei-c.org/ns/1.0',
    ).each_with_index.map do |xml_fragment, rank|
      line = xml_fragment['n']
      new_gsubs = next_level_gsubs(gsubs, level, line)
      new_ref = [ref, line].compact.join('.')

      build_fragment(xml_fragment, new_ref, level, rank, build_fragments(level + 1, new_ref, new_gsubs, other_patterns))
    end
  end

  def next_level_gsubs(gsubs, level, line)
    gsubs.merge("='$#{level}'" => "='#{line}'", "='$#{level + 1}'" => '')
  end

  def build_fragment(xml_fragment, ref, level, rank, children)
    Fragment.new(
      document: document,
      xml: wrap(xml_fragment),
      ref: ref,
      level: level,
      rank: rank,
      children: children,
    )
  end

  def wrap(xml_fragment)
    # Ideally this would use Nokogiri::XML::Builder
    # but I got errors using a generated document not created from a string
    base = Nokogiri::XML(<<-XML.strip_heredoc)
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
        </dts:fragment>
      </TEI>
    XML

    base.xpath(
      '/tei:TEI/dts:fragment',
      tei: 'http://www.tei-c.org/ns/1.0',
      dts: 'https://w3id.org/dts/api#',
    ).first << xml_fragment.clone

    base.to_xml
  end

  def gsub_hash(string, gsubs)
    gsubs.reduce(string) { |m, (k, v)| m.gsub(k, v) }
  end

  def xpath_from_pattern(pattern)
    pattern['replacementPattern'].sub(/\A#xpath\(/, '').sub(/\)\z/, '').gsub("\\'", "'")
  end

  attr_reader :document, :xml
end
