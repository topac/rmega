require 'spec_helper'

module Rmega
  describe Utils do
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
