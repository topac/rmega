require 'integration_spec_helper'

describe 'File download' do

  context 'given a public mega url (a small file)' do

    # A file called testfile.txt containting the string "helloworld!"
    let(:url) { 'https://mega.co.nz/#!MAkg2Iab!bc9Y2U6d93IlRRKVYpcC9hLZjS4G278OPdH6nTFPDNQ' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      related_file = File.join(temp_folder, 'testfile.txt')
      expect(File.read(related_file)).to eq "helloworld!\n"
    end
  end

  context 'given a public mega url (a big file)' do

    # A file called testfile_big_15mb.txt containting the word "topac" repeated 3145728 times (~ 15mb)
    let(:url) { 'https://mega.co.nz/#!NYVkDaLD!BKyN5SRpOaEtGnTcwiAqcxmJc7p-k0IPWKAW-471KRE' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      related_file = File.join(temp_folder, 'testfile_big_15mb.txt')
      md5 = Digest::MD5.file(related_file).hexdigest
      expect(md5).to eq("0451dc82ac003dbef703342e40a1b8f6")
    end
  end
end
