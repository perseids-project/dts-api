require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { should belong_to(:parent).class_name('Collection').optional }

  it { should have_many(:children).class_name('Collection') }
  it { should have_many(:citation_types) }
  it { should have_many(:collection_descriptions) }
  it { should have_many(:collection_titles) }

  it { should have_one(:document) }

  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:title) }

  it { should validate_language_of(:language) }
  it { should canonicalize_language_of(:language) }

  it { should define_enum_for(:display_type).with_values([:collection, :resource]) }

  describe 'uniqueness validations' do
    subject { Collection.new(urn: 'urn', title: 'title') }

    it { should validate_uniqueness_of(:urn) }
  end

  describe 'default values' do
    its(:display_type) { should eq('collection') }
  end

  describe 'counter cache' do
    subject { Collection.create(urn: 'urn', title: 'title') }

    its(:children_count) { should be_zero }

    context 'there are children and document' do
      let(:child) { Collection.new(urn: 'child-urn', title: 'child-title') }

      subject { Collection.create(urn: 'urn', title: 'title', children: [child]) }

      its(:children_count) { should eq(1) }
    end
  end
end
