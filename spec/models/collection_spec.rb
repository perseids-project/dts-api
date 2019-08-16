require 'rails_helper'

RSpec.describe Collection, type: :model do
  it { should belong_to(:parent).class_name('Collection').optional }

  it { should have_many(:children).class_name('Collection') }
  it { should have_many(:documents) }
  it { should have_many(:collection_titles) }

  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:title) }

  describe 'uniqueness validations' do
    subject { Collection.new(urn: 'urn', title: 'title') }

    it { should validate_uniqueness_of(:urn) }
  end

  describe 'language canonicalization' do
    let(:language) { 'eng' }

    subject(:collection) { Collection.new(language: language) }

    its(:language) { should eq('en') }

    context 'the language cannot be shortened' do
      let(:language) { 'grc' }

      its(:language) { should eq('grc') }
    end
  end
end
