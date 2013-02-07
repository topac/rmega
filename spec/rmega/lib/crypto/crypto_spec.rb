require 'spec_helper'

describe Rmega::Crypto do
  describe '#prepare_key' do
    it 'returns the expected value' do
      data = [1684081408, -1313687523, 845282884, -1735274811]
      result = [1380895471, 1656741118, 372674858, 886637722]
      described_class.prepare_key(data).should == result
    end
  end
end
