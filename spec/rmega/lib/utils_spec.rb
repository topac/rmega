require 'spec_helper'

module Rmega
  describe Utils do
    def random_a32_array
      a32_ary = []
      rand(0..20).times { |len| a32_ary << rand(0..2**31)*(rand(2).zero? ? 1 : -1) }
      a32_ary
    end

    describe '#str_to_a32' do
      it 'returns the expected value' do
        string = 'johnsnow'
        a32 = [1785686126, 1936617335]
        expect(described_class.str_to_a32(string)).to eq(a32)
      end

      it 'returns the expected value' do
        string = 'sjobs@apple.com'
        a32 = [1936355170, 1933599088, 1886151982, 1668246784]
        expect(described_class.str_to_a32(string)).to eq(a32)
      end
    end

    describe '#a32_to_str' do
      it 'returns the expected value' do
        a32 = [1953853537, 1660944384]
        string = "tupac" + "\x00\x00\x00"
        expect(described_class.a32_to_str(a32)).to eq(string)
      end

      it 'is the opposite of #str_to_a32' do
        a32_ary = random_a32_array
        str = described_class.a32_to_str a32_ary
        expect(described_class.str_to_a32(str)).to eq(a32_ary)
      end

      it 'has the same result if len is multiplied by 4' do
        a32 = random_a32_array
        expect(described_class.a32_to_str(a32)).to eq described_class.a32_to_str(a32, a32.size*4)
      end
    end

    describe '#base64urlencode' do
      it 'returns the expected value' do
        string = 'ice_lord'
        result = 'aWNlX2xvcmQ'
        expect(described_class.base64urlencode(string)).to eq(result)
      end
    end

    describe '#base64urldecode' do
      it 'returns the expected value' do
        encoded_value = "c29ycnkgaSBhbSBidXN5"
        result = "sorry i am busy"
        expect(described_class.base64urldecode(encoded_value)).to eq(result)
      end
    end
  end
end
