require 'rails_helper'

RSpec.describe '/collections?page=', type: :request do
  let!(:root) { Collection.create(urn: 'default', title: 'Root') }
  let!(:books) { Collection.create(urn: 'books', title: 'collection of books', parent: root) }

  before do
    (1..25).each { |n| Collection.create(urn: "book-#{n}", title: "book-#{n}", parent: books) }
  end

  it 'limits the number of entries for a page' do
    get '/collections/?id=books&page=1'

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
      'member' => (1..10).map do |n|
        { '@id' => "book-#{n}", '@type' => 'Collection', 'title' => "book-#{n}", 'totalItems' => 0 }
      end,
      'title' => 'collection of books',
      'totalItems' => 25,
      'view' => {
        '@id' => '/collections?id=books&page=1',
        '@type' => 'PartialCollectionView',
        'first' => '/collections?id=books&page=1',
        'last' => '/collections?id=books&page=3',
        'next' => '/collections?id=books&page=2',
      },
    )
  end

  it 'shows previous and next in the view' do
    get '/collections/?id=books&page=2'

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
      'member' => (11..20).map do |n|
        { '@id' => "book-#{n}", '@type' => 'Collection', 'title' => "book-#{n}", 'totalItems' => 0 }
      end,
      'title' => 'collection of books',
      'totalItems' => 25,
      'view' => {
        '@id' => '/collections?id=books&page=2',
        '@type' => 'PartialCollectionView',
        'first' => '/collections?id=books&page=1',
        'last' => '/collections?id=books&page=3',
        'next' => '/collections?id=books&page=3',
        'previous' => '/collections?id=books&page=1',
      },
    )
  end

  it 'shows fewer than ten entries if there are fewer than ten for the page' do
    get '/collections/?id=books&page=3'

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
      'member' => (21..25).map do |n|
        { '@id' => "book-#{n}", '@type' => 'Collection', 'title' => "book-#{n}", 'totalItems' => 0 }
      end,
      'title' => 'collection of books',
      'totalItems' => 25,
      'view' => {
        '@id' => '/collections?id=books&page=3',
        '@type' => 'PartialCollectionView',
        'first' => '/collections?id=books&page=1',
        'last' => '/collections?id=books&page=3',
        'previous' => '/collections?id=books&page=2',
      },
    )
  end

  it 'shows the correct id when the nav is parents' do
    get '/collections/?id=books&page=1&nav=parents'

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
        { '@id' => 'default', '@type' => 'Collection', 'title' => 'Root', 'totalItems' => 1 },
      ],
      'title' => 'collection of books',
      'totalItems' => 25,
      'view' => {
        '@id' => '/collections?id=books&nav=parents&page=1',
        '@type' => 'PartialCollectionView',
        'first' => '/collections?id=books&nav=parents&page=1',
        'last' => '/collections?id=books&nav=parents&page=1',
      },
    )
  end

  it 'is invalid when there are no children' do
    get '/collections/?id=book-1&page=1'

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

  it 'is invalid when nav is parents but there are no parents' do
    get '/collections/?id=default&page=1&nav=parents'

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

  it 'does not accept a non-numeric page' do
    get '/collections/?id=books&page=badinput'

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

  it 'does not accept a page less than 1' do
    get '/collections/?id=books&page=0'

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

  it 'does not accept a page greater than the maximum' do
    get '/collections/?id=books&page=4'

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
