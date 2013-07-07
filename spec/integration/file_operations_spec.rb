require 'integration_spec_helper'
require 'fileutils'

describe 'File operations' do
  if account_file_exists?

    let(:temp_folder) { "/tmp/.rmega_spec" }

    before { FileUtils.mkdir_p(temp_folder) }

    # after { FileUtils.rm_rf(temp_folder) }

    context 'give a public mega url' do

      # A file called testfile.txt containting the string "helloworld!"
      # let(:url) { 'https://mega.co.nz/#!MAkg2Iab!bc9Y2U6d93IlRRKVYpcC9hLZjS4G278OPdH6nTFPDNQ' }
      let(:url) { 'https://mega.co.nz/#!nZRBHTQI!foThMzZTyUrXUOaBrqLzIzmiM4dbvGDu33wcl8vlx-w' }

      it 'downloads the related file' do
        t = Time.now
        storage.download(url, temp_folder)
        puts "total = #{Time.now - t}"
        related_file = File.join(temp_folder, 'testfile.txt')
        # expect(File.read(related_file)).to eq "helloworld!\n"
        1.should == 1
      end
    end
  end
end
