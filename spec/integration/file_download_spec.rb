require 'integration_spec_helper'
require 'fileutils'

describe 'File download' do

  if account_file_exists?

    let(:storage) { login }

    context 'given a public mega url (a small file)' do

      # A file called testfile.txt containting the string "helloworld!"
      let(:url) { 'https://mega.co.nz/#!MAkg2Iab!bc9Y2U6d93IlRRKVYpcC9hLZjS4G278OPdH6nTFPDNQ' }

      it 'downloads the related file' do
        storage.download(url, temp_folder)
        related_file = File.join(temp_folder, 'testfile.txt')
        expect(File.read(related_file)).to eq "helloworld!\n"
      end
    end

    context 'given a public mega url (a big file)' do

      # A file called testfile_big_15mb.txt containting the word "topac" repeated 3145728 times (~ 15mb)
      let(:url) { 'https://mega.co.nz/#!NYVkDaLD!BKyN5SRpOaEtGnTcwiAqcxmJc7p-k0IPWKAW-471KRE' }

      it 'downloads the related file' do
        storage.download(url, temp_folder)
        related_file = File.join(temp_folder, 'testfile_big_15mb.txt')

        expect(File.size(related_file)).to eql 15_728_640

        count = 0
        File.open(related_file, 'rb') do |f|
          while (word = f.read(3840))
            break if word != "topac"*768
            count += 768
          end
        end

        expect(count).to eql(15_728_640 / 5)
      end
    end
  end
end
