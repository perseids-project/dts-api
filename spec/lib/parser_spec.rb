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
    end

    after do
      FakeFS.deactivate!
    end

    it 'creates all collections' do
      expect(Collection.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(Collection.count).to eq(7)
    end

    it 'creates all collection titles' do
      expect(CollectionTitle.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(CollectionTitle.count).to eq(8)
    end

    it 'creates all documents' do
      expect(Document.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(Document.count).to eq(2)
    end

    it 'creates all document titles' do
      expect(DocumentTitle.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(DocumentTitle.count).to eq(2)
    end

    it 'creates all document descriptions' do
      expect(DocumentDescription.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(DocumentDescription.count).to eq(2)
    end

    it 'creates the first-level collections' do
      Parser.parse!('canonical-latinLit', dts_collections)

      latin = Collection.find_by(urn: 'urn:perseids:latinLit')
      other = Collection.find_by(urn: 'urn:perseids:otherLit')

      expect(latin).to have_attributes(
        urn: 'urn:perseids:latinLit',
        parent_id: nil,
        title: 'Latin',
      )

      expect(other).to have_attributes(
        urn: 'urn:perseids:otherLit',
        parent_id: nil,
        title: 'Other',
      )

      expect(latin.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959',
          title: 'Publius Ovidius Naso',
        ),
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi1017',
          title: 'Seneca, Lucius Annaeus (Plays)',
        ),
      ])

      expect(other.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:other:phi0969',
          title: 'Persius',
        ),
      ])
    end

    it 'creates the first-level collection titles' do
      Parser.parse!('canonical-latinLit', dts_collections)

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
      Parser.parse!('canonical-latinLit', dts_collections)

      ovid = Collection.find_by(urn: 'urn:cts:latinLit:phi0959')

      expect(ovid.children.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001',
          title: 'Amores',
          language: 'la',
        ),
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi002',
          title: 'Letters',
          language: 'la',
        ),
      ])
    end

    it 'creates the second-level collection titles' do
      Parser.parse!('canonical-latinLit', dts_collections)

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

    it 'creates the documents' do
      Parser.parse!('canonical-latinLit', dts_collections)

      amores = Collection.find_by(urn: 'urn:cts:latinLit:phi0959.phi001')

      expect(amores.documents.order(:id)).to match([
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2',
          xml: a_string_including('<l n="1">Arma gravi numero violentaque bella parabam</l>'),
          title: 'Amores',
          language: 'la',
          description: 'Amores, The Art of Love in Three Books The remedy of love. The art of beauty. The court of love. The history of love amours.',
        ),
        an_object_having_attributes(
          urn: 'urn:cts:latinLit:phi0959.phi001.perseus-eng2',
          xml: a_string_including('<l n="1">For mighty wars I thought to tune my lute,</l>'),
          title: 'Amores, Ovid',
          language: 'en',
          description: 'Amores, Ovid',
        ),
      ])
    end

    it 'creates the document titles' do
      Parser.parse!('canonical-latinLit', dts_collections)

      english = Document.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-eng2')

      expect(english.document_titles.order(:id)).to match([
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

    it 'creates the document descriptions' do
      Parser.parse!('canonical-latinLit', dts_collections)

      latin = Document.find_by(urn: 'urn:cts:latinLit:phi0959.phi001.perseus-lat2')

      expect(latin.document_descriptions.order(:id)).to match([
        an_object_having_attributes(
          description: 'Amores, The Art of Love in Three Books The remedy of love. The art of beauty. The court of love. The history of love amours.',
          language: 'en',
        ),
        an_object_having_attributes(
          description: 'Amores, Epistulae, Medicamina faciei femineae, Ars amatoria, Remedia amoris, R. Ehwald, edidit ex Rudolphi Merkelii recognitione, Leipzig, B. G. Teubner, 1907',
          language: 'la',
        ),
      ])
    end
  end
end
