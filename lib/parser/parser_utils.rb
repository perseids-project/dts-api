require 'utils'

class Parser
  module ParserUtils
    include Utils

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
  end
end
