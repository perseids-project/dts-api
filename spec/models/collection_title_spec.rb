require 'rails_helper'

RSpec.describe CollectionTitle, type: :model do
  it { should belong_to(:collection) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:language) }

  describe 'uniqueness validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title') }

    subject(:collection_title) { CollectionTitle.new(title: 'title', language: 'en', collection: collection) }

    it { should validate_uniqueness_of(:language).scoped_to(:collection_id) }
  end

  describe 'language validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title') }
    let(:language) { 'en' }

    subject(:collection_title) { CollectionTitle.new(title: 'title', language: language, collection: collection) }

    it { should be_valid }

    context 'the language code does not exist' do
      let(:language) { '123' }

      it { should_not be_valid }

      it 'has the correct error message' do
        collection_title.valid?

        expect(collection_title.errors[:language]).to eq(['is not a valid language code'])
      end
    end
  end

  describe 'language canonicalization' do
    let(:language) { 'eng' }

    subject(:collection_title) { CollectionTitle.new(language: language) }

    its(:language) { should eq('en') }

    context 'the language cannot be shortened' do
      let(:language) { 'grc' }

      its(:language) { should eq('grc') }
    end
  end
end
