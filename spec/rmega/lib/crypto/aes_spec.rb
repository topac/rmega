require 'spec_helper'

describe Rmega::Crypto::Aes do
  describe '#encrypt' do
    it 'returns the expect result' do
      data = [447236115, -1585310199, -1864656235, -1137211605]
      key = [1380895471, 1656741118, 372674858, 886637722]
      result = [-1780228062, 945709550, 1098116349, -1813988988]
      described_class.encrypt(key, data).should == result
    end
  end
end