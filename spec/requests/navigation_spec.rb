require 'rails_helper'

RSpec.describe '/navigation', type: :request do
  let!(:collection) do
    Collection.create(urn: 'urn', title: 'title', display_type: 'resource', cite_structure: %w[book chapter line])
  end
  let!(:document) { Document.create(urn: 'urn', xml: '<test/>', collection: collection) }

  let!(:book1) { Fragment.create(document: document, ref: '1', level: 1, rank: 0, xml: '<book n="1"/>') }
  let!(:chapter11) do
    Fragment.create(document: document, ref: '1.1', level: 2, rank: 1, parent: book1, xml: '<chapter n="1"/>')
  end
  let!(:line111) do
    Fragment.create(document: document, ref: '1.1.1', level: 3, rank: 2, parent: chapter11, xml: '<line n="1"/>')
  end
  let!(:line112) do
    Fragment.create(document: document, ref: '1.1.2', level: 3, rank: 3, parent: chapter11, xml: '<line n="2"/>')
  end
  let!(:line113) do
    Fragment.create(document: document, ref: '1.1.3', level: 3, rank: 4, parent: chapter11, xml: '<line n="3"/>')
  end
  let!(:chapter12) do
    Fragment.create(document: document, ref: '1.2', level: 2, rank: 5, parent: book1, xml: '<chapter n="2"/>')
  end
  let!(:line121) do
    Fragment.create(document: document, ref: '1.2.1', level: 3, rank: 6, parent: chapter12, xml: '<line n="1"/>')
  end
  let!(:book2) { Fragment.create(document: document, ref: '2', level: 1, rank: 7, xml: '<book n="2"/>') }
  let!(:chapter21) do
    Fragment.create(document: document, ref: '2.1', level: 2, rank: 8, parent: book2, xml: '<chapter n="1"/>')
  end
  let!(:book3) { Fragment.create(document: document, ref: '3', level: 1, rank: 9, xml: '<book n="3"/>') }
  let!(:chapter31) do
    Fragment.create(document: document, ref: '3.1', level: 2, rank: 10, parent: book3, xml: '<chapter n="1"/>')
  end

  specify 'Passage References as children of a textual Resource' do
    get '/navigation?id=urn'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?groupBy=1&id=urn&level=1',
      'dts:citeDepth' => 3,
      'dts:level' => 1,
      'member' => [
        { 'ref' => '1' },
        { 'ref' => '2' },
        { 'ref' => '3' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Passage References as descendants of a textual Resource' do
    get '/navigation?id=urn&level=2'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?groupBy=1&id=urn&level=2',
      'dts:citeDepth' => 3,
      'dts:level' => 2,
      'member' => [
        { 'ref' => '1.1' },
        { 'ref' => '1.2' },
        { 'ref' => '2.1' },
        { 'ref' => '3.1' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Passage References as children of a Passage' do
    get '/navigation?id=urn&ref=1'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?groupBy=1&id=urn&level=2&ref=1',
      'dts:citeDepth' => 3,
      'dts:level' => 2,
      'member' => [
        { 'ref' => '1.1' },
        { 'ref' => '1.2' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Passage References as descendants of a Passage' do
    get '/navigation?id=urn&ref=1&level=3'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?groupBy=1&id=urn&level=3&ref=1',
      'dts:citeDepth' => 3,
      'dts:level' => 3,
      'member' => [
        { 'ref' => '1.1.1' },
        { 'ref' => '1.1.2' },
        { 'ref' => '1.1.3' },
        { 'ref' => '1.2.1' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Ranges of passage references' do
    get '/navigation?id=urn&start=1&end=2'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?end=2&groupBy=1&id=urn&level=1&start=1',
      'dts:citeDepth' => 3,
      'dts:level' => 1,
      'member' => [
        { 'ref' => '1' },
        { 'ref' => '2' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Descendant passage reference ranges' do
    get '/navigation?id=urn&start=1&end=2&level=2'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?end=2&groupBy=1&id=urn&level=2&start=1',
      'dts:citeDepth' => 3,
      'dts:level' => 2,
      'member' => [
        { 'ref' => '1.1' },
        { 'ref' => '1.2' },
        { 'ref' => '2.1' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Descendant passage reference ranges (deeper level)' do
    get '/navigation?id=urn&start=1.1&end=2.1&level=2'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?end=2.1&groupBy=1&id=urn&level=2&start=1.1',
      'dts:citeDepth' => 3,
      'dts:level' => 2,
      'member' => [
        { 'ref' => '1.1' },
        { 'ref' => '1.2' },
        { 'ref' => '2.1' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Passages grouped by the provider' do
    get '/navigation?id=urn&ref=1&level=3&groupBy=3'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => '/navigation?groupBy=3&id=urn&level=3&ref=1',
      'dts:citeDepth' => 3,
      'dts:level' => 3,
      'member' => [
        { 'start' => '1.1.1', 'end' => '1.1.3' },
        { 'start' => '1.2.1', 'end' => '1.2.1' },
      ],
      'dts:passage' => '/documents?id=urn{&ref}{&start}{&end}',
    )
  end

  specify 'Document not found' do
    get '/navigation/?id=sandwiches'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)).to match(
      '@context' => 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type' => 'Error',
      'description' => 'Not Found',
      'statusCode' => 404,
      'title' => 'Not Found',
    )
  end

  specify 'Reference not found' do
    get '/navigation/?id=urn&ref=sandwiches'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)).to match(
      '@context' => 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type' => 'Error',
      'description' => 'Not Found',
      'statusCode' => 404,
      'title' => 'Not Found',
    )
  end

  specify 'Start not found' do
    get '/navigation/?id=urn&start=sandwiches'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)).to match(
      '@context' => 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type' => 'Error',
      'description' => 'Not Found',
      'statusCode' => 404,
      'title' => 'Not Found',
    )
  end

  specify 'End not found' do
    get '/navigation/?id=urn&start=1&end=sandwiches'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:not_found)
    expect(JSON.parse(response.body)).to match(
      '@context' => 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type' => 'Error',
      'description' => 'Not Found',
      'statusCode' => 404,
      'title' => 'Not Found',
    )
  end

  specify 'Given ref and start' do
    get '/navigation/?id=urn&ref=1&start=1'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)).to match(
      '@context' => 'http://www.w3.org/ns/hydra/context.jsonld',
      '@type' => 'Error',
      'description' => 'Bad Request',
      'statusCode' => 400,
      'title' => 'Bad Request',
    )
  end
end
