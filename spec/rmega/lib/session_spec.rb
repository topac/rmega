require 'spec_helper'

module Rmega
  describe Session do
    describe '#hash_password' do
      { 1  => "m\xD9\xF7\xEC\xB2F\x89\xC45\xA1O|Q\xDACM",
        16 => "\x02\xBDXOzW.\x95xB\xF7O]\\\r\xD5",
        20 => "\x17\x99x\xAF\e\xE3&\xE6\xF7\x8B\f\x92\x1AY\xF9,",
      }.each do |n, r|
        context "when the password is #{n}-bytes long" do

          let(:password) { 'a'*n }

          let(:result) { r.force_encoding('BINARY') }

          it 'returns the expected value' do
            expect(subject.hash_password(password)).to eq(result)
          end
        end
      end
    end

    describe '#user_hash' do
      it 'returns the expected value' do
        string = 'sjobs@apple.com'
        key = "\xCF\x8C\xF1p\xD8\xF4k\xC4\xCD\xAD\xE8M;\xF6}\x96".force_encoding('BINARY')
        expect(subject.user_hash(key, string)).to eq('snWuwnlz45w')
      end
    end
  end
end
