require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  it 'displays the entrypoint information' do
    get '/'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => 'dts/EntryPoint.jsonld',
      '@id' => '/',
      '@type' => 'EntryPoint',
      'collections' => '/collections',
      'documents' => '/documents',
      'navigation' => '/navigation',
    )
  end
end
