require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { should belong_to(:parent).class_name('Collection').optional }

  it { should have_many(:children).class_name('Collection') }
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

  describe 'display type conditional presence validations' do
    let(:display_type) { 'collection' }

    subject { Collection.new(display_type: display_type) }

    it { should validate_absence_of(:document) }
    # it { should validate_absence_of(:cite_structure) } TODO https://github.com/thoughtbot/shoulda-matchers/issues/1240

    context 'it is a resource' do
      let(:display_type) { 'resource' }

      it { should validate_presence_of(:document) }
      it { should validate_presence_of(:cite_structure) }
    end
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

  describe '#cite_depth' do
    subject { Collection.new(cite_structure: %w[a b c]) }

    its(:cite_depth) { should eq(3) }
  end

  describe '#last_page' do
    let(:children_count) { 0 }

    subject(:collection) { Collection.new(children_count: children_count) }

    its(:last_page) { should eq(0) }

    context 'there is one child' do
      let(:children_count) { 1 }

      its(:last_page) { should eq(1) }
    end

    context 'there are ten children' do
      let(:children_count) { 10 }

      its(:last_page) { should eq(1) }
    end

    context 'there are more than ten children' do
      let(:children_count) { 19 }

      its(:last_page) { should eq(2) }
    end

    context 'the page size is not ten' do
      let(:children_count) { 19 }

      it 'does the calculation using the correct page size' do
        expect(collection.last_page(page_size: 19)).to eq(1)
      end
    end
  end

  describe '#paginated_children' do
    let(:children) { (1..25).map { |n| Collection.new(urn: n.to_s, title: n.to_s) } }

    subject(:collection) { Collection.create(urn: 'urn', title: 'title', children: children) }

    it 'correctly gets the first page' do
      expect(collection.paginated_children(1).map(&:urn)).to eq(%w[1 2 3 4 5 6 7 8 9 10])
    end

    it 'correctly gets the second page' do
      expect(collection.paginated_children(2).map(&:urn)).to eq(%w[11 12 13 14 15 16 17 18 19 20])
    end

    it 'correctly gets the third page' do
      expect(collection.paginated_children(3).map(&:urn)).to eq(%w[21 22 23 24 25])
    end
  end
end
