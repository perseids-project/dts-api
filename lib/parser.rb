require 'utils'

class Parser
  include Utils

  def self.parse!(name, collections)
    new(name, collections).parse!
  end

  def initialize(name, collections)
    @name = name
    @collections = collections
  end

  def parse!
    find_group_cts_files.each do |group_file|
      parent = parse_group_cts_file(group_file)

      find_work_cts_files(group_file).each do |work_file|
        parse_work_cts_file(work_file, parent)
      end
    end
  end

  attr_reader :name, :collections

  private

  def find_group_cts_files
    Dir.glob(path(name, 'data', '*', '__cts__.xml')).sort
  end

  def find_work_cts_files(group_cts_file)
    group_cts_directory = File.dirname(group_cts_file)

    Dir.glob(File.join(group_cts_directory, '*', '__cts__.xml')).sort
  end

  def parse_group_cts_file(file)
    cts = Nokogiri::XML(File.read(file))

    text_group = collect_tags(cts, 'textgroup')[0]
    urn = text_group['urn']

    parent = find_or_create_group_parent(urn)
    collection = Collection.find_or_initialize_by(parent: parent, urn: urn)

    group_names = collect_tags(text_group, 'groupname')
    build_collection_titles(collection, group_names)

    collection.tap(&:save!)
  end

  def parse_work_cts_file(file, parent)
    cts = Nokogiri::XML(File.read(file))

    work = collect_tags(cts, 'work')[0]
    urn = work['urn']
    language = work['xml:lang']

    collection = Collection.find_or_initialize_by(parent: parent, urn: urn)

    collection.language = language.presence

    titles = collect_tags(work, 'title')
    build_collection_titles(collection, titles)
    build_documents(file, collection, work)

    collection.tap(&:save!)
  end

  def build_documents(file, collection, work)
    directory = File.dirname(file)

    editions = collect_tags(work, 'edition')
    translations = collect_tags(work, 'translation')

    build_documents_from_tags(editions + translations, directory, collection)
  end

  def find_or_create_group_parent(urn)
    parent = collections.find { |c| urn =~ c[:match] }

    Collection.find_or_create_by(urn: parent[:urn], title: parent[:title])
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

  def build_collection_titles(collection, tags)
    generic_title = nil
    collection.collection_titles = []

    tags.each do |tag|
      if tag['xml:lang'].present? && tag.text.squish.present?
        collection.collection_titles << CollectionTitle.new(
          title: tag.text.squish,
          language: tag['xml:lang'],
        )
      else
        generic_title = tag.text.squish
      end
    end

    set_collection_title(collection, generic_title)
  end

  def build_documents_from_tags(tags, directory, collection)
    collection.documents = []

    tags.each do |edition|
      urn = edition['urn']
      language = edition['xml:lang'].presence || collection.language
      filename = "#{urn.gsub(/\A.*:/, '')}.xml"
      filepath = path(directory, filename)

      next unless File.exist?(filepath)

      document = Document.new(
        urn: urn,
        title: collection.title,
        xml: File.read(filepath),
        language: language,
      )
      build_document_titles_and_descriptions(document, edition)

      collection.documents << document
    end
  end

  def set_collection_title(collection, generic_title)
    collection.title = generic_title.presence ||
                       collection.collection_titles.select { |ct| ct.language == 'en' }.first&.title.presence ||
                       collection.collection_titles.first.title
  end

  def build_document_titles_and_descriptions(document, work)
    titles = collect_tags(work, 'label')
    descriptions = collect_tags(work, 'description')

    generic_title = nil
    document.document_titles = []

    titles.each do |title|
      if title['xml:lang'].present? && title.text.squish.present?
        document.document_titles << DocumentTitle.new(
          title: title.text.squish,
          language: title['xml:lang'],
        )
      else
        generic_title = title.text.squish
      end
    end

    set_document_title(document, generic_title)

    generic_description = nil
    document.document_descriptions = []

    descriptions.each do |description|
      if description['xml:lang'].present? && description.text.squish.present?
        document.document_descriptions << DocumentDescription.new(
          description: description.text.squish,
          language: description['xml:lang'],
        )
      else
        generic_description = description.text.squish
      end
    end

    set_document_description(document, generic_description)
  end

  def set_document_title(document, generic_title)
    document.title = generic_title.presence ||
                     document.document_titles.select { |dt| dt.language == 'en' }.first&.title&.presence ||
                     document.document_titles.first.title
  end

  def set_document_description(document, generic_description)
    document.description = generic_description.presence ||
                           document.document_descriptions.select { |dd| dd.language == 'en' }.first&.description.presence ||
                           document.document_descriptions.first&.description.presence ||
                           document.title
  end
end
