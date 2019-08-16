require 'rails_helper'
require 'utils'

RSpec.describe Utils do
  class Foo
    include Utils
  end

  subject(:utils) { Foo.new }

  describe '#path' do
    it 'generates the correct path' do
      expect(utils.path('a', 'b', 'c')).to eq(Rails.root.join('texts', 'a', 'b', 'c').to_s)
    end
  end
end
