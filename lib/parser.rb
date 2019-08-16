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
      parse_group_cts_file(group_file)
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

    parent = find_or_create_parent(urn)
    collection = Collection.find_or_initialize_by(parent: parent, urn: urn)

    group_names = collect_tags(text_group, 'groupname')
    build_collection_titles(collection, group_names)

    collection.save!
  end

  def find_or_create_parent(urn)
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

  def build_collection_titles(collection, group_names)
    generic_title = nil
    collection.collection_titles = []

    group_names.each do |group_name|
      if group_name['xml:lang'].present?
        collection.collection_titles << CollectionTitle.new(
          title: group_name.text,
          language: group_name['xml:lang'],
        )
      else
        generic_title = group_name.text
      end
    end

    set_title(collection, generic_title)
  end

  def set_title(collection, generic_title)
    collection.collection_titles = collection.collection_titles.uniq { |ct| ISO_639.find(ct.language).alpha3 }

    collection.title = generic_title ||
                       collection.collection_titles.find { |ct| ISO_639.find(ct.language).alpha2 == 'en' }&.title ||
                       collection.collection_titles.first.title
  end
end
