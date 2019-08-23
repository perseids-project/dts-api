require 'rails_helper'

RSpec.describe DocumentTitle, type: :model do
  it { should belong_to(:document) }

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:language) }

  it { should validate_language_of(:language) }
  it { should canonicalize_language_of(:language) }
end
