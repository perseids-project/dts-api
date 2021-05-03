require 'rails_helper'
require 'utils'

RSpec.describe Utils do
  subject(:utils) { Class.new { include Utils }.new }

  describe '#path' do
    it 'generates the correct path' do
      expect(utils.path('a', 'b', 'c')).to eq(Rails.root.join('texts', 'a', 'b', 'c').to_s)
    end
  end
end
