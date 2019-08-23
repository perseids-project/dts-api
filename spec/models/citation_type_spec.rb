require 'rails_helper'

RSpec.describe CitationType, type: :model do
  it { should belong_to(:document) }

  it { should validate_presence_of(:level) }
  it { should validate_presence_of(:citation_type) }

  it { should validate_numericality_of(:level).only_integer }

  describe 'uniqueness validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title') }
    let(:document) do
      Document.new(urn: 'urn', xml: '<test/>', title: 'document', language: 'en', collection: collection)
    end

    subject(:citation_type) { CitationType.new(level: 1, citation_type: 'passage', document: document) }

    it { should validate_uniqueness_of(:level).scoped_to(:document_id) }
  end
end
