# encoding: utf-8
require 'spec_helper'

describe Rmega::Utils do
  describe '#str_to_a32' do
    it 'returns the expected value' do
      string = 'johnsnow'
      a32 = [1785686126, 1936617335]
      described_class.str_to_a32(string).should == a32
    end

    it 'returns the expected value' do
      string = 'sjobs@apple.com'
      a32 = [1936355170, 1933599088, 1886151982, 1668246784]
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

  describe '#base64urlencode' do
    it 'returns the expected value' do
      string = 'ice_lord'
      result = 'aWNlX2xvcmQ'
      described_class.base64urlencode(string).should == result
    end
  end

  describe '#a32_to_base64' do
    it 'returns the expected value' do
      a32 = [-24267049, 354638668, -845953520, 1348163508]
      result = '_o221xUjW0zNk8YQUFtXtA'
      described_class.a32_to_base64(a32).should == result
    end
  end

  describe '#base64urldecode' do
    it 'returns the expected value' do
      encoded_value = "c29ycnkgaSBhbSBidXN5"
      result = "sorry i am busy"
      described_class.base64urldecode(encoded_value).should == result
    end
  end

  describe '#base64_to_a32' do
    it 'returns the expected value' do
      encoded_value = "YmF0dGxlc3RhciBnYWxhY3RpY2E"
      result = [1650553972, 1818588020, 1634869351, 1634492771, 1953063777]
      described_class.base64_to_a32(encoded_value).should == result
    end
  end
end
