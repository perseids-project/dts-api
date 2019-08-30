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
