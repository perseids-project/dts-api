class StartStopFragmentPresenter < ApplicationPresenter
  attr_accessor :document, :start, :stop
  delegate :urn, to: :document

  def initialize(document, start, stop)
    @document = document
    @start = start
    @stop = stop
  end

  def xml
    start_rank = start.rank
    stop_rank = stop.descendent_rank
    level = start.level

    fragments = document.fragments.where(rank: (start_rank..stop_rank), level: level).order(:rank)
    original_xml, *xmls = fragments.map(&:xml)

    combine_xml_documents(original_xml, xmls)
  end

  def links
    link_headers.map { |name, fragments| link(name, fragments) }.compact
  end

  private

  def combine_xml_documents(original_xml, xmls)
    Nokogiri::XML(original_xml).tap do |base|
      node = base.xpath('/tei:TEI/dts:fragment', tei: 'http://www.tei-c.org/ns/1.0', dts: 'https://w3id.org/dts/api#').first

      xmls.each do |xml|
        node << Nokogiri::XML(xml).xpath('/tei:TEI/dts:fragment', tei: 'http://www.tei-c.org/ns/1.0', dts: 'https://w3id.org/dts/api#').children
      end
    end.to_xml
  end

  def link_headers
    {
      prev: start.previous_range(stop),
      next: start.next_range(stop),
      up: start.parent_range(stop),
      first: start.first_range(stop),
      last: start.last_range(stop),
    }
  end

  def link(name, fragments)
    return nil if fragments.empty?

    path = documents_path(id: urn, start: fragments.first.ref, end: fragments.last.ref)

    "<#{path}>; rel=\"#{name}\""
  end
end
