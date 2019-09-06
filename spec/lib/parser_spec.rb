require 'rails_helper'
require 'parser'

RSpec.describe Parser do
  describe '.parse!' do
    let(:dts_collections) do
      [
        { match: /^urn:cts:latinLit:/, title: 'Latin', urn: 'urn:perseids:latinLit' },
        { match: //, title: 'Other', urn: 'urn:perseids:otherLit' },
      ]
    end

    before do
      FakeFS.activate!

      FakeFS::FileSystem.clone(
        Rails.root.join('spec', 'fixtures', 'texts').to_s,
        Rails.root.join('texts').to_s,
      )

      Parser.parse!('canonical-latinLit', dts_collections)
    end

    after do
      FakeFS.deactivate!
    end

    it 'creates all collections' do
      expect(Collection.count).to eq(10)
    end

    it 'creates all collection titles' do
      expect(CollectionTitle.count).to eq(10)
    end

    it 'creates all document descriptions' do
      expect(CollectionDescription.count).to eq(2)
    end

    it 'creates all documents' do
      expect(Document.count).to eq(2)
    end

    it 'creates all fragments' do
      expect(Fragment.count).to eq(35)
    end

    it 'creates the root collection' do
      root = Collection.find_by(urn: 'default')

      expect(root).to have_attributes(
        urn: 'default',
        display_type: 'collection',
        title: 'Root',
        children_count: 2,
      )
    end

    it 'creates the first-level collections' do
      root = Collection.find_by(urn: 'default')
      latin = Collection.find_by(urn: 'urn:perseids:latinLit')
      other = Collection.find_by(urn: 'urn:perseids:otherLit')

      expect(root.children.order(:id)).to eq([latin, other])

      expect(latin.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959',
          display_type: 'collection',
          title: 'Publius Ovidius Naso',
          children_count: 2,
        ),
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi1017',
          display_type: 'collection',
          title: 'Seneca, Lucius Annaeus (Plays)',
          children_count: 0,
        ),
      ])

      expect(other.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:other:phi0969',
          display_type: 'collection',
          title: 'Persius',
          children_count: 0,
        ),
      ])
    end

    it 'creates the first-level collection titles' do
      ovid = Collection.find_by(urn: 'urn:cts:latinLit:phi0959')

      expect(ovid.collection_titles.order(:id)).to match([
        an_object_having_attributes(
          title: 'Ovid',
          language: 'en',
        ),
        an_object_having_attributes(
          title: 'Ovidius',
          language: 'la',
        ),
        an_object_having_attributes(
          title: 'Ὀβίδιος',
          language: 'grc',
        ),
      ])
    end

    it 'creates the second-level collections' do
      ovid = Collection.find_by(urn: 'urn:cts:latinLit:phi0959')

      expect(ovid.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001',
          display_type: 'collection',
          title: 'Amores',
          language: 'la',
          children_count: 2,
        ),
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi002',
          display_type: 'collection',
          title: 'Letters',
          language: 'la',
          children_count: 0,
        ),
      ])
    end

    it 'creates the second-level collection titles' do
      letters = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi002')

      expect(letters.collection_titles.order(:id)).to match([
        an_object_having_attributes(
          title: 'Letters',
          language: 'en',
        ),
        an_object_having_attributes(
          title: 'Epistulae',
          language: 'la',
        ),
      ])
    end

    it 'creates the resources' do
      amores = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi001')

      expect(amores.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2',
          display_type: 'resource',
          title: 'Amores',
          language: 'la',
          description: 'Amores, The Art of Love in Three Books The remedy of love. ' \
                       'The art of beauty. The court of love. The history of love amours.',
          children_count: 0,
          cite_structure: %w[book poem line],
        ),
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001.perseus-eng2',
          display_type: 'resource',
          title: 'Amores, Ovid',
          language: 'en',
          description: 'Amores, Ovid',
          children_count: 0,
          cite_structure: %w[book poem section],
        ),
      ])
    end

    it 'creates the documents' do
      latin = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2')
      english = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-eng2')

      expect(latin.document).to match(
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2',
          xml: a_string_including('<l n="1">Arma gravi numero violentaque bella parabam</l>'),
        ),
      )

      expect(english.document).to match(
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001.perseus-eng2',
          xml: a_string_including('<l n="1">For mighty wars I thought to tune my lute,</l>'),
        ),
      )
    end

    it 'creates the fragments for documents' do
      document = Document.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2')

      expect(document.fragments.order(:id)).to match([
        an_object_having_attributes(ref: '1', level: 1, rank: 0),
        an_object_having_attributes(ref: '1.ep', level: 2, rank: 1),
        an_object_having_attributes(ref: '1.ep.1', level: 3, rank: 2),
        an_object_having_attributes(ref: '1.ep.2', level: 3, rank: 3),
        an_object_having_attributes(ref: '1.ep.3', level: 3, rank: 4),
        an_object_having_attributes(ref: '1.1', level: 2, rank: 5),
        an_object_having_attributes(ref: '1.1.1', level: 3, rank: 6),
        an_object_having_attributes(ref: '1.1.2', level: 3, rank: 7),
        an_object_having_attributes(ref: '1.1.3', level: 3, rank: 8),
        an_object_having_attributes(ref: '1.2', level: 2, rank: 9),
        an_object_having_attributes(ref: '1.2.1', level: 3, rank: 10),
        an_object_having_attributes(ref: '1.2.2', level: 3, rank: 11),
        an_object_having_attributes(ref: '1.2.3', level: 3, rank: 12),
        an_object_having_attributes(ref: '2', level: 1, rank: 13),
        an_object_having_attributes(ref: '2.1', level: 2, rank: 14),
        an_object_having_attributes(ref: '2.1.1', level: 3, rank: 15),
        an_object_having_attributes(ref: '2.1.2', level: 3, rank: 16),
        an_object_having_attributes(ref: '2.1.3', level: 3, rank: 17),
      ])
    end

    it 'generates the correct parent child relationships for the fragments' do
      document = Document.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2')

      fragment2 = Fragment.find_by(document: document, ref: '2')
      fragment21 = Fragment.find_by(document: document, ref: '2.1')
      fragment213 = Fragment.find_by(document: document, ref: '2.1.3')

      expect(fragment2.parent).to be_nil
      expect(fragment21.parent).to eq(fragment2)
      expect(fragment213.parent).to eq(fragment21)
      expect(fragment213.children).to be_empty
    end

    it 'generates the correct xml for the fragments' do
      document = Document.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2')

      fragment2 = Fragment.find_by(document: document, ref: '2')
      fragment21 = Fragment.find_by(document: document, ref: '2.1')
      fragment213 = Fragment.find_by(document: document, ref: '2.1.3')

      expect(fragment2.xml).to be_equivalent_to(%(
        <?xml version="1.0" encoding="UTF-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
            <div type="textpart" subtype="book" n="2">
              <head>Liber secundus</head>
              <div type="textpart" subtype="poem" n="1">
                <l n="1">Hoc quoque conposui Paelignis natus aquosis,</l>
                <l n="2" rend="indent">Ille ego nequitiae Naso poeta meae.</l>
                <l n="3">Hoc quoque iussit Amor — procul hinc, procul este, severae!</l>
              </div>
            </div>
          </dts:fragment>
        </TEI>
      ))

      expect(fragment21.xml).to be_equivalent_to(%(
        <?xml version="1.0" encoding="UTF-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
            <div type="textpart" subtype="poem" n="1">
              <l n="1">Hoc quoque conposui Paelignis natus aquosis,</l>
              <l n="2" rend="indent">Ille ego nequitiae Naso poeta meae.</l>
              <l n="3">Hoc quoque iussit Amor — procul hinc, procul este, severae!</l>
            </div>
          </dts:fragment>
        </TEI>
      ))

      expect(fragment213.xml).to be_equivalent_to(%(
        <?xml version="1.0" encoding="UTF-8"?>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
          <dts:fragment xmlns:dts="https://w3id.org/dts/api#">
            <l n="3">Hoc quoque iussit Amor — procul hinc, procul este, severae!</l>
          </dts:fragment>
        </TEI>
      ))
    end

    it 'creates the collection titles for resources' do
      english = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-eng2')

      expect(english.collection_titles.order(:id)).to match([
        an_object_having_attributes(
          title: 'Amores, Ovid',
          language: 'en',
        ),
        an_object_having_attributes(
          title: 'Amores, Ovidius',
          language: 'la',
        ),
      ])
    end

    it 'creates the collection descriptions for resources' do
      latin = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2')

      expect(latin.collection_descriptions.order(:id)).to match([
        an_object_having_attributes(
          description: 'Amores, The Art of Love in Three Books The remedy of love. The art of beauty. ' \
                       'The court of love. The history of love amours.',
          language: 'en',
        ),
        an_object_having_attributes(
          description: 'Amores, Epistulae, Medicamina faciei femineae, Ars amatoria, Remedia amoris, ' \
                       'R. Ehwald, edidit ex Rudolphi Merkelii recognitione, Leipzig, B. G. Teubner, 1907',
          language: 'la',
        ),
      ])
    end
  end
end
