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

  describe 'navigation methods' do
    let!(:collection) do
      Collection.create(urn: 'urn', title: 'title', display_type: 'resource', cite_structure: %w[book chapter])
    end
    let!(:document) { Document.create(urn: 'urn', xml: '<document/>', collection: collection) }

    let!(:parent1) do
      Fragment.create(
        ref: 'p1',
        xml: '<p1/>',
        level: 1,
        rank: 1,
        descendent_rank: 4,
        document: document,
      )
    end
    let!(:child11) do
      Fragment.create(
        ref: 'c11',
        xml: '<c11/>',
        level: 2,
        rank: 2,
        descendent_rank: 2,
        parent: parent1,
        document: document,
      )
    end
    let!(:child12) do
      Fragment.create(
        ref: 'c12',
        xml: '<c12/>',
        level: 2,
        rank: 3,
        descendent_rank: 3,
        parent: parent1,
        document: document,
      )
    end
    let!(:child13) do
      Fragment.create(
        ref: 'c13',
        xml: '<c13/>',
        level: 2,
        rank: 4,
        descendent_rank: 4,
        parent: parent1,
        document: document,
      )
    end

    let!(:parent2) do
      Fragment.create(ref: 'p2', xml: '<p2/>', level: 1, rank: 5, descendent_rank: 8, document: document)
    end
    let!(:child21) do
      Fragment.create(
        ref: 'c21',
        xml: '<c21/>',
        level: 2,
        rank: 6,
        descendent_rank: 6,
        parent: parent2,
        document: document,
      )
    end
    let!(:child22) do
      Fragment.create(
        ref: 'c22',
        xml: '<c22/>',
        level: 2,
        rank: 7,
        descendent_rank: 7,
        parent: parent2,
        document: document,
      )
    end
    let!(:child23) do
      Fragment.create(
        ref: 'c23',
        xml: '<c23/>',
        level: 2,
        rank: 8,
        descendent_rank: 8,
        parent: parent2,
        document: document,
      )
    end

    let!(:parent3) do
      Fragment.create(ref: 'p3', xml: '<p3/>', level: 1, rank: 9, descendent_rank: 9, document: document)
    end

    describe '#previous_fragment' do
      it 'gets the previous passage of a parent fragment' do
        expect(parent2.previous_fragment).to eq(parent1)
      end

      it 'returns nil if there is no previous passage' do
        expect(parent1.previous_fragment).to be_nil
      end

      it 'gets the previous passage of a child fragment' do
        expect(child12.previous_fragment).to eq(child11)
      end

      it 'gets the last fragment of the previous parent' do
        expect(child21.previous_fragment).to eq(child13)
      end
    end

    describe '#previous_range' do
      it 'gets the previous range of a parent fragment' do
        expect(parent3.previous_range(parent3)).to eq([parent2, parent2])
      end

      it 'is empty if there is no previous range' do
        expect(parent1.previous_range(parent2)).to be_empty
      end

      it 'gets the previous range of a child fragment' do
        expect(child21.previous_range(child22)).to eq([child12, child13])
      end

      it 'squishes the previous range if there are not enough children' do
        expect(child12.previous_range(child13)).to eq([child11, child11])
      end

      it 'creates a range that straddles the two parents' do
        expect(child22.previous_range(child23)).to eq([child13, child21])
      end
    end

    describe '#next_fragment' do
      it 'gets the next passage of a parent fragment' do
        expect(parent1.next_fragment).to eq(parent2)
      end

      it 'returns nil if there is no next passage' do
        expect(parent3.next_fragment).to be_nil
      end

      it 'gets the next passage of a child fragment' do
        expect(child12.next_fragment).to eq(child13)
      end

      it 'gets the first fragment of the next parent' do
        expect(child13.next_fragment).to eq(child21)
      end
    end

    describe '#next_range' do
      it 'gets the next range of a parent fragment' do
        expect(parent1.next_range(parent1)).to eq([parent2, parent2])
      end

      it 'is empty if there is no next range' do
        expect(parent2.next_range(parent3)).to be_empty
      end

      it 'gets the next range of a child fragment' do
        expect(child12.next_range(child13)).to eq([child21, child22])
      end

      it 'squishes the next range if there are not enough children' do
        expect(child21.next_range(child22)).to eq([child23, child23])
      end

      it 'creates a range that straddles the two parents' do
        expect(child11.next_range(child12)).to eq([child13, child21])
      end
    end

    describe '#first_fragment' do
      it 'gets the first passage for a parent fragment' do
        expect(parent2.first_fragment).to eq(parent1)
      end

      it 'gets the first passage for a child fragment' do
        expect(child21.first_fragment).to eq(child11)
      end
    end

    describe '#first_range' do
      it 'gets the first range for a parent fragment' do
        expect(parent2.first_range(parent3)).to eq([parent1, parent2])
      end

      it 'gets the first range for a child fragment' do
        expect(child21.first_range(child23)).to eq([child11, child13])
      end
    end

    describe '#last_fragment' do
      it 'gets the last passage for a parent fragment' do
        expect(parent1.last_fragment).to eq(parent3)
      end

      it 'gets the last passage for a child fragment' do
        expect(child13.last_fragment).to eq(child23)
      end
    end

    describe '#last_range' do
      it 'gets the last range for a parent fragment' do
        expect(parent1.last_range(parent2)).to eq([parent2, parent3])
      end

      it 'gets the last range for a child fragment' do
        expect(child11.last_range(child13)).to eq([child21, child23])
      end
    end

    describe '#parent_range' do
      it 'is empty for a parent fragment' do
        expect(parent1.parent_range(parent2)).to be_empty
      end

      it 'gets the parent range for a child fragment' do
        expect(child13.parent_range(child21)).to eq([parent1, parent2])
      end
    end
  end
end
