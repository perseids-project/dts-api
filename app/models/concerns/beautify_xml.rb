module BeautifyXml
  extend ActiveSupport::Concern

  module ClassMethods
    def beautify(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=") do |xml|
          self[attribute] = xml.present? ? Nokogiri::XML(xml).to_xml : xml
        end
      end
    end
  end
end
