require 'spec_helper'

describe Rmega::Utils do
  describe '#str_to_a32' do
    it 'returns the expected value' do
      string = 'johnsnow'
      a32 = [1785686126, 1936617335]
      described_class.str_to_a32(string).should == a32
    end
  end

  describe '#a32_to_str' do
    it 'returns the expected value' do
      a32 = [1953853537, 1660944384]
      string = "tupac" + "\x00\x00\x00"
      described_class.a32_to_str(a32).should == string
    end
  end
end
