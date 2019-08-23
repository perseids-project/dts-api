require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { should belong_to(:parent).class_name('Collection').optional }

  it { should have_many(:children).class_name('Collection') }
  it { should have_many(:documents) }
  it { should have_many(:collection_titles) }

  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:title) }

  it { should validate_language_of(:language) }
  it { should canonicalize_language_of(:language) }

  describe 'uniqueness validations' do
    subject { Collection.new(urn: 'urn', title: 'title') }

    it { should validate_uniqueness_of(:urn) }
  end

  describe '#total_items' do
    subject { Collection.create(urn: 'urn', title: 'title') }

    its(:total_items) { should be_zero }

    context 'there are children and document' do
      let(:child) { Collection.new(urn: 'child-urn', title: 'child-title') }
      let(:document) { Document.new(urn: 'document-urn', xml: '<test/>', title: 'document-title', language: 'en') }

      subject { Collection.create(urn: 'urn', title: 'title', children: [child], documents: [document]) }

      its(:total_items) { should eq(2) }
    end
  end

  describe '#available_languages' do
    subject { Collection.new }

    its(:available_languages) { should be_nil }

    context 'there is a collection language' do
      subject { Collection.new(language: 'en') }

      its(:available_languages) { should eq('en') }
    end

    context 'there are document languages' do
      let(:english_document) { Document.new(language: 'en') }
      let(:greek_document) { Document.new(language: 'grc') }

      subject { Collection.new(language: 'grc', documents: [english_document, greek_document]) }

      its(:available_languages) { should eq(%w[en grc]) }
    end
  end
end
