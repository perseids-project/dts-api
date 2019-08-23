require 'parser/collection_parser'

class Parser
  def self.parse!(name, collections)
    CollectionParser.new(name, collections).parse!
  end
end
