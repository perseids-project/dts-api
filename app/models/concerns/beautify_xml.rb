module BeautifyXml
  extend ActiveSupport::Concern

  module ClassMethods
    def beautify(*attributes)
      attributes.each do |attribute|
        define_method("#{attribute}=") do |xml|
          if xml.present?
            doc = Nokogiri::XML(xml)

            if doc.errors.any? { |e| e.str1 == 'Huge input lookup1' }
              doc = Nokogiri::XML(xml, &:huge)
            end

            self[attribute] = doc.to_xml
          else
            self[attribute] = xml
          end
        end
      end
    end
  end
end
