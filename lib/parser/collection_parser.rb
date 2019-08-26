require 'parser/parser_utils'
require 'parser/document_parser'

class Parser
  class CollectionParser
    include ParserUtils

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

    private

    attr_reader :name, :collections

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
      DocumentParser.new(file, collection, work).build

      collection.tap(&:save!)
    end

    def find_or_create_group_parent(urn)
      parent = collections.find { |c| urn =~ c[:match] }

      Collection.find_or_create_by(urn: parent[:urn], title: parent[:title], parent: root_collection)
    end

    def root_collection
      @root_collection ||= Collection.find_or_create_by(urn: 'default', title: 'Root')
    end
  end
end
