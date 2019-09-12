require 'parser/collection_parser'

class Parser
  def self.parse!(name, collections, logger = Logger.new(STDOUT))
    CollectionParser.new(name, collections, logger).parse!
  end
end
