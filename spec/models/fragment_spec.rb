require 'rails_helper'

RSpec.describe Fragment, type: :model do
  it { should belong_to(:document) }
  it { should belong_to(:parent).class_name('Fragment').optional }

  it { should have_many(:children).class_name('Fragment') }

  it { should validate_presence_of(:ref) }
  it { should validate_presence_of(:xml) }
  it { should validate_presence_of(:level) }
  it { should validate_presence_of(:descendent_rank) }

  it { should validate_numericality_of(:level).only_integer }
  it { should validate_numericality_of(:rank).only_integer }
  it { should validate_numericality_of(:descendent_rank).only_integer }

  describe 'uniqueness validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title', display_type: 'resource', cite_structure: ['book']) }
    let(:document) do
      Document.new(urn: 'urn', xml: '<test><div/></test>', collection: collection)
    end

    subject(:fragment) do
      Fragment.new(ref: 'ref', xml: '<div/>', level: 1, rank: 1, descendent_rank: 1, document: document)
    end

    it { should validate_uniqueness_of(:ref).scoped_to(:document_id) }
    it { should validate_uniqueness_of(:rank).scoped_to(:document_id) }
  end
end
