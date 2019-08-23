require 'rails_helper'

RSpec.describe Document, type: :model do
  it { should belong_to(:collection) }

  it { should have_many(:citation_types) }
  it { should have_many(:fragments) }
  it { should have_many(:document_titles) }
  it { should have_many(:document_descriptions) }

  it { should validate_presence_of(:urn) }
  it { should validate_presence_of(:xml) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:language) }

  it { should validate_language_of(:language) }
  it { should canonicalize_language_of(:language) }

  it { should beautify_xml_of(:xml) }

  describe 'uniqueness validations' do
    let(:collection) { Collection.new(urn: 'urn', title: 'title') }

    subject { Document.new(urn: 'urn', xml: '<test/>', title: 'title', language: 'en', collection: collection) }

    it { should validate_uniqueness_of(:urn) }
  end
end
