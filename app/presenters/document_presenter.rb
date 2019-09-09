class DocumentPresenter < ApplicationPresenter
  attr_accessor :id, :collection_id, :xml_proc, :links_proc, :ref, :start, :stop

  def self.from_document(document)
    new(
      id: document.urn,
      collection_id: document.collection.urn,
      xml_proc: -> { document.xml },
      links_proc: -> { [] },
    )
  end

  def self.from_start_and_stop(start_fragment, stop_fragment)
    document = start_fragment.document
    id = document.urn

    new(
      id: id,
      collection_id: document.collection.urn,
      xml_proc: start_stop_xml_proc(start_fragment, stop_fragment),
      links_proc: start_stop_links_proc(id, start_fragment, stop_fragment),
    )
  end

  def self.from_fragment(fragment, start:, stop:)
    document = fragment.document
    id = document.urn

    new(
      id: id,
      collection_id: document.collection.urn,
      xml_proc: -> { fragment.xml },
      ref: fragment.ref,
      start: start,
      stop: stop,
      links_proc: fragment_links_proc(id, fragment),
    )
  end

  def self.start_stop_xml_proc(start_fragment, stop_fragment)
    lambda do
      start_rank = start_fragment.rank
      stop_rank = stop_fragment.descendent_rank
      level = start_fragment.level

      fragments = start_fragment.document.fragments.where(rank: (start_rank..stop_rank), level: level).order(:rank)
      original_xml, *xmls = fragments.map(&:xml)

      combine_xml_documents(original_xml, xmls)
    end
  end

  def self.combine_xml_documents(original_xml, xmls)
    Nokogiri::XML(original_xml).tap do |base|
      node = base.xpath('/tei:TEI/dts:fragment', tei: 'http://www.tei-c.org/ns/1.0', dts: 'https://w3id.org/dts/api#').first

      xmls.each do |xml|
        node << Nokogiri::XML(xml).xpath('/tei:TEI/dts:fragment', tei: 'http://www.tei-c.org/ns/1.0', dts: 'https://w3id.org/dts/api#').children
      end
    end.to_xml
  end

  def self.start_stop_links_proc(id, start_fragment, stop_fragment)
    lambda do
      [].tap do |links|
        {
          prev: start_fragment.previous_range(stop_fragment),
          next: start_fragment.next_range(stop_fragment),
          first: start_fragment.first_range(stop_fragment),
          last: start_fragment.last_range(stop_fragment),
        }.each do |k, v|
          links << "<#{documents_path(id: id, start: v.first.ref, end: v.last.ref)}>; rel=\”#{k}\”" unless v.empty?
        end
      end
    end
  end

  def self.fragment_links_proc(id, fragment)
    lambda do
      [].tap do |links|
        {
          prev: fragment.previous_fragment&.ref,
          next: fragment.next_fragment&.ref,
          first: fragment.first_fragment.ref,
          last: fragment.last_fragment.ref,
        }.each do |k, v|
          links << "<#{documents_path(id: id, ref: v)}>; rel=\”#{k}\”" if v
        end
      end
    end
  end

  private_class_method :start_stop_xml_proc, :fragment_links_proc

  def valid?
    return false if ref && start
    return false unless start_and_stop_valid?

    true
  end

  def xml
    xml_proc.call
  end

  def link_header
    (links_proc.call + [
      "<#{navigation_path(id: id)}>; rel=\”contents\”",
      "<#{collections_path(id: collection_id)}>; rel=\”collection\”",
    ]).join(', ')
  end

  private

  def start_and_stop_valid?
    (start && stop) || (!start && !stop)
  end
end
