require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:collection) }

  it { should have_many(:fragments) }

  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:xml) }

  it { should delegate_method(:cite_depth).to(:collection) }

  describe 'uniqueness validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title', display_type: 'resource', cite_structure: ['book']) }

    subject { Document.new(urn: 'urn', xml: '<test/>', collection: collection) }

    it { should validate_uniqueness_of(:urn) }
  end
end
