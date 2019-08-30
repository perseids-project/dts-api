require 'rails_helper'

RSpec.describe '/collections', type: :request do
  let!(:root) { Collection.create(urn: 'default', title: 'Root') }
  let!(:books) { Collection.create(urn: 'books', title: 'collection of books', parent: root) }
  let!(:magazines) { Collection.create(urn: 'magazines', title: 'collection of magazines', parent: root) }
  let!(:fiction) { Collection.create(urn: 'fiction', title: 'fiction books', parent: books) }
  let!(:nonfiction) { Collection.create(urn: 'nonfiction', title: 'nonfiction books', parent: books) }
  let!(:news) do
    Collection.create(
      urn: 'news',
      title: 'news magazines',
      description: 'magazines about the news',
      parent: magazines,
      language: 'en',
    )
  end
  let!(:histories) do
    Collection.create!(
      urn: 'histories',
      title: 'The Histories',
      description: 'The Histories by Herodotus of Halicarnassus',
      display_type: 'resource',
      parent: nonfiction,
      language: 'grc',
      cite_structure: %w[book chapter section],
      document: Document.new(urn: 'urn', xml: '<test/>'),
    )
  end
  let!(:peloponnesian_war) do
    Collection.create!(
      urn: 'peloponnesian-war',
      title: 'History of the Peloponnesian War',
      description: 'History of the Peloponnesian War by Thucydides',
      display_type: 'resource',
      parent: nonfiction,
      language: 'grc',
      cite_structure: [],
      document: Document.new(urn: 'urn', xml: '<test/>'),
    )
  end
  let!(:news_title_en) { CollectionTitle.create(title: 'news magazines', language: 'en', collection: news) }
  let!(:news_title_fr) { CollectionTitle.create(title: "magazines d'information", language: 'fr', collection: news) }
  let!(:news_description_en) do
    CollectionDescription.create(description: 'magazines about the news', language: 'en', collection: news)
  end
  let!(:news_description_fr) do
    CollectionDescription.create(description: 'magazines sur les nouvelles', language: 'fr', collection: news)
  end

  it 'lists all top-level collections' do
    get '/collections'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'default',
      '@type' => 'Collection',
      'member' => [
        { '@id' => 'books', '@type' => 'Collection', 'title' => 'collection of books', 'totalItems' => 2 },
        { '@id' => 'magazines', '@type' => 'Collection', 'title' => 'collection of magazines', 'totalItems' => 1 },
      ],
      'title' => 'Root',
      'totalItems' => 2,
    )
  end

  it 'lists all members of a particular collection' do
    get '/collections/?id=books'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'books',
      '@type' => 'Collection',
      'member' => [
        { '@id' => 'fiction', '@type' => 'Collection', 'title' => 'fiction books', 'totalItems' => 0 },
        { '@id' => 'nonfiction', '@type' => 'Collection', 'title' => 'nonfiction books', 'totalItems' => 2 },
      ],
      'title' => 'collection of books',
      'totalItems' => 2,
    )
  end

  it 'lists title and language information' do
    get '/collections/?id=news'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'news',
      '@type' => 'Collection',
      'description' => 'magazines about the news',
      'dts:dublincore' => {
        'dc:description' => [
          {
            '@language' => 'en',
            '@value' => 'magazines about the news',
          },
          {
            '@language' => 'fr',
            '@value' => 'magazines sur les nouvelles',
          },
        ],
        'dc:language' => 'en',
        'dc:title' => [
          {
            '@language' => 'en',
            '@value' => 'news magazines',
          },
          {
            '@language' => 'fr',
            '@value' => "magazines d'information",
          },
        ],
      },
      'title' => 'news magazines',
      'totalItems' => 0,
    )
  end

  it 'lists title and language information of members' do
    get '/collections/?id=magazines'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'magazines',
      '@type' => 'Collection',
      'member' => [
        {
          '@id' => 'news',
          '@type' => 'Collection',
          'description' => 'magazines about the news',
          'dts:dublincore' => {
            'dc:description' => [
              {
                '@language' => 'en',
                '@value' => 'magazines about the news',
              },
              {
                '@language' => 'fr',
                '@value' => 'magazines sur les nouvelles',
              },
            ],
            'dc:language' => 'en',
            'dc:title' => [
              {
                '@language' => 'en',
                '@value' => 'news magazines',
              },
              {
                '@language' => 'fr',
                '@value' => "magazines d'information",
              },
            ],
          },
          'title' => 'news magazines',
          'totalItems' => 0,
        },
      ],
      'title' => 'collection of magazines',
      'totalItems' => 1,
    )
  end

  it 'shows that the default collection has no parent' do
    get '/collections/?nav=parents'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'default',
      '@type' => 'Collection',
      'title' => 'Root',
      'totalItems' => 2,
    )
  end

  it 'shows the parent of a collection' do
    get '/collections/?id=fiction&nav=parents'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'fiction',
      '@type' => 'Collection',
      'member' => [
        { '@id' => 'books', '@type' => 'Collection', 'title' => 'collection of books', 'totalItems' => 2 },
      ],
      'title' => 'fiction books',
      'totalItems' => 0,
    )
  end

  it 'shows the parent of a top-level collection' do
    get '/collections/?id=books&nav=parents'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'books',
      '@type' => 'Collection',
      'member' => [
        { '@id' => 'default', '@type' => 'Collection', 'title' => 'Root', 'totalItems' => 2 },
      ],
      'title' => 'collection of books',
      'totalItems' => 2,
    )
  end

  it 'returns extra fields when collection is a resource' do
    get '/collections/?id=histories'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'histories',
      '@type' => 'Resource',
      'description' => 'The Histories by Herodotus of Halicarnassus',
      'dts:citeDepth' => 3,
      'dts:citeStructure' => [{
        'dts:citeStructure' => [{
          'dts:citeType' => 'chapter',
          'dts:citeStructure' => [{
            'dts:citeType' => 'section',
          }],
        }],
        'dts:citeType' => 'book',
      }],
      'dts:download' => '/documents?id=histories',
      'dts:dublincore' => { 'dc:language' => 'grc' },
      'dts:passage' => '/documents?id=histories',
      'dts:references' => '/navigation?id=histories',
      'title' => 'The Histories',
      'totalItems' => 0,
    )
  end

  it 'skips cite structure when there is none' do
    get '/collections/?id=peloponnesian-war'

    expect(response.content_type).to eq('application/ld+json; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to match(
      '@context' => {
        '@vocab' => 'https://www.w3.org/ns/hydra/core#',
        'dc' => 'http://purl.org/dc/terms/',
        'dts' => 'https://w3id.org/dts/api#',
      },
      '@id' => 'peloponnesian-war',
      '@type' => 'Resource',
      'description' => 'History of the Peloponnesian War by Thucydides',
      'dts:citeDepth' => 0,
      'dts:download' => '/documents?id=peloponnesian-war',
      'dts:dublincore' => { 'dc:language' => 'grc' },
      'dts:passage' => '/documents?id=peloponnesian-war',
      'dts:references' => '/navigation?id=peloponnesian-war',
      'title' => 'History of the Peloponnesian War',
      'totalItems' => 0,
    )
  end

  it 'does not accept a malformed nav' do
    get '/collections/?nav=badinput'

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

  it 'returns not found when there is no collection' do
    get '/collections/?id=sandwiches'

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
end
