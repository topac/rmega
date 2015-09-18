require 'integration_spec_helper'

describe 'File download' do

  context 'given a public mega url (a small file)' do

    let(:url) { 'https://mega.nz/#!QQhADCbL!vUY_phwxvkC004t5NKx7vynL16SvFfHYFkiX5vUlgjQ' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      related_file = File.join(temp_folder, 'testfile.txt')
      expect(File.read(related_file)).to eq "helloworld!\n"
    end
  end

  context 'given a public mega url (a big file)' do

    let(:url) { 'https://mega.nz/#!oAhCnBKR!CPeG8X92nBjvFsBF9EprZNW_TqIUwItHMkF9G2IZEIo' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      related_file = File.join(temp_folder, 'testfile_big_15mb.txt')
      md5 = Digest::MD5.file(related_file).hexdigest
      expect(md5).to eq("0451dc82ac003dbef703342e40a1b8f6")
    end
  end
end
