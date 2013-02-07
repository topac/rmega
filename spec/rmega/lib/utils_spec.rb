require 'spec_helper'

describe Rmega::Utils do
  describe '#str_to_a32' do
    it 'returns the expected value' do
      string = 'johnsnow'
      a32 = [1785686126, 1936617335]
      described_class.str_to_a32(string).should == a32
    end
  end
end
