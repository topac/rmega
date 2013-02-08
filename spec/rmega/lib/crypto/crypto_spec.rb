require 'spec_helper'

describe Rmega::Crypto do
  describe '#prepare_key' do
    it 'returns the expected value' do
      data = [1684081408, -1313687523, 845282884, -1735274811]
      result = [1380895471, 1656741118, 372674858, 886637722]
      described_class.prepare_key(data).should == result
    end
  end

  describe '#prepare_key_pw' do
    it 'returns the expected value' do
      password = "my kingdom 4 a horse"
      result = [-24267049, 354638668, -845953520, 1348163508]
      described_class.prepare_key_pw(password).should == result
    end
  end

  describe '#stringhash' do
    it 'returns the expected value' do
      string = 'sjobs@apple.com'
      key = [-812846736, -655070268, -844240819, 1006009750]
      described_class.stringhash(key, string).should == 'snWuwnlz45w'
    end
  end
end
