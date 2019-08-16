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

    collection.language = language if language.present?

    titles = collect_tags(work, 'title')
    build_collection_titles(collection, titles)

    collection.tap(&:save!)
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
      if tag['xml:lang'].present?
        collection.collection_titles << CollectionTitle.new(
          title: tag.text,
          language: tag['xml:lang'],
        )
      else
        generic_title = tag.text
      end
    end

    set_title(collection, generic_title)
  end

  def set_title(collection, generic_title)
    collection.collection_titles = collection.collection_titles.uniq(&:language)

    collection.title = generic_title ||
                       collection.collection_titles.find { |ct| ct.language == 'en' }&.title ||
                       collection.collection_titles.first.title
  end
end
