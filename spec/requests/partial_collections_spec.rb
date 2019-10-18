require 'rails_helper'

RSpec.describe '/collections?page=', type: :request do
  let!(:root) { Collection.create(urn: 'default', title: 'Root') }
  let!(:books) { Collection.create(urn: 'books', title: 'collection of books', parent: root) }

  before do
    (1..25).each { |n| Collection.create(urn: "book-#{n}", title: "book-#{n}", parent: books) }
  end

  specify 'Paginated child collection' do
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

  specify 'Paginated child collection with next and previous' do
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

  specify 'Paginated child collection with fewer than 10 entries' do
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

  specify 'Paginated child collection with parent navigation' do
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
        { '@id' => 'default', '@type' => 'Collection', 'title' => 'Root', 'totalItems' => 0 },
      ],
      'title' => 'collection of books',
      'totalItems' => 1,
      'view' => {
        '@id' => '/collections?id=books&nav=parents&page=1',
        '@type' => 'PartialCollectionView',
        'first' => '/collections?id=books&nav=parents&page=1',
        'last' => '/collections?id=books&nav=parents&page=1',
      },
    )
  end

  specify 'Paginated child collection with no children' do
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

  specify 'Paginated child collection with parent navigation but no parents' do
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

  specify 'Paginated child collection with invalid page number' do
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

  specify 'Paginated child with page number below range' do
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

  specify 'Paginated child with page number above range' do
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
