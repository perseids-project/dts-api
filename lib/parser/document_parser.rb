require 'parser/parser_utils'

class Parser
  class DocumentParser
    include ParserUtils

    def initialize(file, collection, work)
      @file = file
      @collection = collection
      @work = work
    end

    def build!
      directory = File.dirname(file)

      editions = collect_tags(work, 'edition')
      translations = collect_tags(work, 'translation')

      build_documents_from_tags(editions + translations, directory, collection)
    end

    private

    attr_reader :file, :collection, :work

    def build_documents_from_tags(tags, directory, collection)
      collection.documents = []

      tags.each do |edition|
        urn = edition['urn']
        language = edition['xml:lang'].presence || collection.language
        filepath = path(directory, "#{urn.gsub(/\A.*:/, '')}.xml")

        next unless File.exist?(filepath)

        document = Document.new(
          urn: urn,
          title: collection.title,
          xml: File.read(filepath),
          language: language,
        )

        build_document_fields(document, edition)
        collection.documents << document
      end
    end

    def build_document_fields(document, edition)
      build_document_titles(document, edition)
      build_document_descriptions(document, edition)
    end

    def build_document_titles(document, work)
      titles = collect_tags(work, 'label')

      generic_title = nil
      document.document_titles = []

      titles.each do |title|
        text = title.text.squish

        if title['xml:lang'].present? && text.present?
          document.document_titles << DocumentTitle.new(
            title: text,
            language: title['xml:lang'],
          )
        else
          generic_title = text
        end
      end

      set_document_title(document, generic_title)
    end

    def build_document_descriptions(document, work)
      descriptions = collect_tags(work, 'description')

      generic_description = nil
      document.document_descriptions = []

      descriptions.each do |description|
        text = description.text.squish

        if description['xml:lang'].present? && text.present?
          document.document_descriptions << DocumentDescription.new(
            description: text,
            language: description['xml:lang'],
          )
        else
          generic_description = text
        end
      end

      set_document_description(document, generic_description)
    end

    def set_document_title(document, generic_title)
      document.title = generic_title.presence ||
                       document.document_titles.select { |dt| dt.language == 'en' }.first&.title&.presence ||
                       document.document_titles.first.title
    end

    def set_document_description(doc, generic_description)
      doc.description = generic_description.presence ||
                        doc.document_descriptions.select { |dd| dd.language == 'en' }.first&.description.presence ||
                        doc.document_descriptions.first&.description.presence ||
                        doc.title
    end
  end
end
