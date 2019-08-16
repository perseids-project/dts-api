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

    it 'creates the collections' do
      expect(Collection.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(Collection.count).to eq(5)

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

    it 'creates the collection titles' do
      expect(CollectionTitle.count).to eq(0)

      Parser.parse!('canonical-latinLit', dts_collections)

      expect(CollectionTitle.count).to eq(5)

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
  end
end
