require 'rails_helper'

RSpec.describe '/documents', type: :request do
  let!(:collection) do
    Collection.create(urn: 'urn', title: 'title', display_type: 'resource', cite_structure: %w[book chapter])
  end
  let!(:document) { Document.create(urn: 'urn', xml: '<entire-document/>', collection: collection) }
  let!(:xml1) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="book" n="1">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">abc</l>
            </div>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml11) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">abc</l>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml2) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="book" n="2">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">def</l>
            </div>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml21) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">def</l>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml3) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="book" n="3">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">ghi</l>
            </div>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml31) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">ghi</l>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml4) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="book" n="4">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">jkl</l>
            </div>
            <div type="textpart" subtype="chapter" n="2">
              <l n="1">mno</l>
            </div>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml41) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">jkl</l>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:xml42) do
    %(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="2">
            <l n="1">mno</l>
          </div>
        </dts:fragment>
      </TEI>
    )
  end
  let!(:book1) { Fragment.create(document: document, ref: '1', level: 1, rank: 0, descendent_rank: 1, xml: xml1) }
  let!(:chapter11) do
    Fragment.create(document: document, parent: book1, ref: '1.1', level: 2, rank: 1, descendent_rank: 1, xml: xml11)
  end

  let!(:book2) { Fragment.create(document: document, ref: '2', level: 1, rank: 2, descendent_rank: 3, xml: xml2) }
  let!(:chapter21) do
    Fragment.create(document: document, parent: book2, ref: '2.1', level: 2, rank: 3, descendent_rank: 3, xml: xml21)
  end

  let!(:book3) { Fragment.create(document: document, ref: '3', level: 1, rank: 4, descendent_rank: 5, xml: xml3) }
  let!(:chapter31) do
    Fragment.create(document: document, parent: book3, ref: '3.1', level: 2, rank: 5, descendent_rank: 5, xml: xml31)
  end

  let!(:book4) { Fragment.create(document: document, ref: '4', level: 1, rank: 6, descendent_rank: 8, xml: xml4) }
  let!(:chapter41) do
    Fragment.create(document: document, parent: book4, ref: '4.1', level: 2, rank: 7, descendent_rank: 7, xml: xml41)
  end
  let!(:chapter42) do
    Fragment.create(document: document, parent: book4, ref: '4.2', level: 2, rank: 8, descendent_rank: 8, xml: xml42)
  end

  specify 'Retrieve a passage using ref' do
    get '/documents/?id=urn&ref=2'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(response.headers['Link']).to eq(%(
      </documents?id=urn&ref=1>; rel="prev",
      </documents?id=urn&ref=3>; rel="next",
      </documents?id=urn&ref=1>; rel="first",
      </documents?id=urn&ref=4>; rel="last",
      </navigation?id=urn>; rel="contents",
      </collections?id=urn>; rel="collection"
    ).squish)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="book" n="2">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">def</l>
            </div>
          </div>
        </dts:fragment>
      </TEI>
    ))
  end

  specify 'Retrieve a passage with a parent using ref' do
    get '/documents/?id=urn&ref=3.1'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(response.headers['Link']).to eq(%(
      </documents?id=urn&ref=2.1>; rel="prev",
      </documents?id=urn&ref=4.1>; rel="next",
      </documents?id=urn&ref=3>; rel="up",
      </documents?id=urn&ref=1.1>; rel="first",
      </documents?id=urn&ref=4.2>; rel="last",
      </navigation?id=urn>; rel="contents",
      </collections?id=urn>; rel="collection"
    ).squish)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">ghi</l>
          </div>
        </dts:fragment>
      </TEI>
    ))
  end

  specify 'Retrieve a passage using start and end' do
    get '/documents/?id=urn&start=3&end=4'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(response.headers['Link']).to eq(%(
      </documents?end=2&id=urn&start=1>; rel="prev",
      </documents?end=2&id=urn&start=1>; rel="first",
      </documents?end=4&id=urn&start=3>; rel="last",
      </navigation?id=urn>; rel="contents",
      </collections?id=urn>; rel="collection"
    ).squish)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="book" n="3">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">ghi</l>
            </div>
          </div>
          <div type="textpart" subtype="book" n="4">
            <div type="textpart" subtype="chapter" n="1">
              <l n="1">jkl</l>
            </div>
            <div type="textpart" subtype="chapter" n="2">
              <l n="1">mno</l>
            </div>
          </div>
        </dts:fragment>
      </TEI>
    ))
  end

  specify 'Retrieve a passage using start and end across books' do
    get '/documents/?id=urn&start=1.1&end=2.1'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(response.headers['Link']).to eq(%(
      </documents?end=4.1&id=urn&start=3.1>; rel="next",
      </documents?end=2&id=urn&start=1>; rel="up",
      </documents?end=2.1&id=urn&start=1.1>; rel="first",
      </documents?end=4.2&id=urn&start=4.1>; rel="last",
      </navigation?id=urn>; rel="contents",
      </collections?id=urn>; rel="collection"
    ).squish)
    expect(response.body).to be_equivalent_to(%(
      <?xml version="1.0" encoding="UTF-8"?>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">abc</l>
          </div>
          <div type="textpart" subtype="chapter" n="1">
            <l n="1">def</l>
          </div>
        </dts:fragment>
      </TEI>
    ))
  end

  specify 'Retrieve a full document' do
    get '/documents/?id=urn'

    expect(response.content_type).to eq('application/tei+xml; charset=utf-8')
    expect(response).to have_http_status(:ok)
    expect(response.headers['Link']).to eq(%(
      </navigation?id=urn>; rel="contents",
      </collections?id=urn>; rel="collection"
    ).squish)
    expect(response.body).to be_equivalent_to(%(
      <entire-document/>
    ))
  end

  specify 'Malformed query' do
    get '/documents/?id=urn&ref=1&start=1'

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

  specify 'Document not found' do
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
