class ErrorPresenter < ApplicationPresenter
  attr_accessor :status, :title

  def json
    {
      '@context': 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type': 'Error',
      statusCode: status,
      title: title,
      description: title,
    }
  end

  def xml
    Nokogiri::XML::Builder.new do |xml|
      xml.error(statusCode: status, xmlns: 'https://w3id.org/dts/api#') do
        xml.title title
        xml.description title
      end
    end.to_xml
  end
end
