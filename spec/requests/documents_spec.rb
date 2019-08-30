require 'rails_helper'

RSpec.describe '/documents', type: :request do
  let(:collection) { Collection.new(urn: 'urn', title: 'title', display_type: 'resource', cite_structure: ['book']) }

  let!(:document) { Document.create(urn: 'urn', xml: '<test/>', collection: collection) }

  it 'displays the document xml' do
    get '/documents?id=urn'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0"?>
      <test/>
    ))
  end

  it 'does not accept malformed queries' do
    get '/documents/'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:bad_request)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0"?>
      <error statusCode="400" xmlns="https://w3id.org/dts/api#">
        <title>Bad Request</title>
        <description>Bad Request</description>
      </error>
    ))
  end

  it 'returns not found when there is no document' do
    get '/documents/?id=sandwiches'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:not_found)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0"?>
      <error statusCode="404" xmlns="https://w3id.org/dts/api#">
        <title>Not Found</title>
        <description>Not Found</description>
      </error>
    ))
  end
end
