require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:collection) }

  it { should have_many(:citation_types) }
  it { should have_many(:fragments) }

  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:xml) }

  describe 'uniqueness validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title') }

    subject { Document.new(urn: 'urn', xml: '<test/>', collection: collection) }

    it { should validate_uniqueness_of(:urn) }
  end

  describe '#beautify_xml' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title') }

    subject(:document) { Document.new(urn: 'urn', xml: '<test></test>', collection: collection) }

    it 'beautifies the xml on save' do
      expect(document.xml).to eq('<test></test>')

      document.save

      expect(document.xml).to eq(%(<?xml version="1.0"?>\n<test/>\n))
    end
  end
end
