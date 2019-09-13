require 'utils'

class Parser
  module ParserUtils
    include Utils

    private

    def read(file)
      logger.info("Parsing file #{file}")
      File.read(file)
    end

    def collect_tags(xml, tag)
      tags = []
      if xml.namespaces.member?('xmlns:ti')
        tags += xml.xpath("./ti:#{tag}")
      elsif xml.namespaces.member?('xmlns:cts')
        tags += xml.xpath("./cts:#{tag}")
      elsif xml.namespaces['xmlns'] == 'http://chs.harvard.edu/xmlns/cts'
        tags += xml.xpath("./cts:#{tag}", cts: 'http://chs.harvard.edu/xmlns/cts')
      end

      tags
    end

    def build_collection_titles(collection, titles)
      generic_title = nil
      collection_titles = []

      titles.each do |title|
        text = title.text.squish

        if title['xml:lang'].present? && text.present?
          collection_titles << CollectionTitle.new(
            title: text,
            language: title['xml:lang'],
          )
        else
          generic_title = text
        end
      end

      collection.collection_titles = collection_titles if titles_differ?(collection, collection_titles)

      set_collection_title(collection, generic_title)
    end

    def titles_differ?(collection, titles)
      !collection.collection_titles ||
        collection.collection_titles.map { |t| [t.title, t.language] } != titles.map { |t| [t.title, t.language] }
    end

    def build_collection_descriptions(collection, descriptions)
      generic_description = nil
      collection.collection_descriptions = []

      descriptions.each do |description|
        text = description.text.squish

        if description['xml:lang'].present? && text.present?
          collection.collection_descriptions << CollectionDescription.new(
            description: text,
            language: description['xml:lang'],
          )
        else
          generic_description = text
        end
      end

      set_collection_description(collection, generic_description)
    end

    def set_collection_title(collection, generic_title)
      title = generic_title.presence ||
              collection.collection_titles.select { |t| t.language == 'en' }.first&.title&.presence ||
              collection.collection_titles.first.title

      collection.title = title
    end

    def set_collection_description(collection, generic_description)
      description = generic_description.presence ||
                    collection.collection_descriptions.select { |d| d.language == 'en' }.first&.description.presence ||
                    collection.collection_descriptions.first&.description.presence ||
                    collection.title

      collection.description = description
    end
  end
end
