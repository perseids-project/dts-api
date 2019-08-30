require 'parser/parser_utils'
require 'parser/cite_structure_parser'

class Parser
  class DocumentParser
    include ParserUtils

    def initialize(file, parent, work)
      @file = file
      @parent = parent
      @work = work
    end

    def build
      directory = File.dirname(file)

      editions = collect_tags(work, 'edition')
      translations = collect_tags(work, 'translation')

      parent.children = resources_from_tags(editions + translations, directory)
    end

    private

    attr_reader :file, :parent, :work

    def resources_from_tags(tags, directory)
      tags.map { |edition| resource_from_edition(edition, directory) }.compact
    end

    def resource_from_edition(edition, directory)
      urn = edition['urn']
      filepath = path(directory, "#{urn.gsub(/\A.*:/, '')}.xml")

      return nil unless File.exist?(filepath)

      file = File.read(filepath)

      Collection.new(
        urn: urn,
        display_type: 'resource',
        title: parent.title,
        language: get_language_from_edition(edition),
        document: Document.new(urn: urn, xml: file),
        cite_structure: CiteStructureParser.cite_structure(file),
      ).tap { |collection| build_collection_fields(collection, edition) }
    end

    def get_language_from_edition(edition)
      edition['xml:lang'].presence || parent.language
    end

    def build_collection_fields(collection, edition)
      build_collection_titles(collection, collect_tags(edition, 'label'))
      build_collection_descriptions(collection, collect_tags(edition, 'description'))
    end
  end
end
