# encoding: utf-8
require 'spec_helper'

describe Rmega::Utils do
  def random_a32_array
    a32_ary = []
    rand(0..20).times { |len| a32_ary << rand(0..2**31)*(rand(2).zero? ? 1 : -1) }
    a32_ary
  end

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

  describe '#format_bytes' do
    it 'converts to the correct unit' do
      described_class.format_bytes(1024, 2).should == '1.0kb'
      described_class.format_bytes(1024**2).should == '1.0MB'
    end
  end

  describe '#a32_to_str' do
    it 'returns the expected value' do
      a32 = [1953853537, 1660944384]
      string = "tupac" + "\x00\x00\x00"
      described_class.a32_to_str(a32).should == string
    end

    it 'is the opposite of #str_to_a32' do
      a32_ary = random_a32_array
      str = described_class.a32_to_str a32_ary
      described_class.str_to_a32(str).should == a32_ary
    end

    it 'has the same result if len is multiplied by 4' do
      a32 = random_a32_array
      described_class.a32_to_str(a32).should == described_class.a32_to_str(a32, a32.size*4)
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

  describe '#b2s' do
    it 'returns the expected value' do
      value = [123, 213123, 321354, 5435, 4545, 23434, 6665656]
      result = [1706407936, 95985664, 297861121, 1404044519, 1241527304, 805306491]
      described_class.str_to_a32(described_class.b2s(value)).should == result
    end
  end
end
