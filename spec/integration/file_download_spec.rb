require 'integration_spec_helper'

describe 'File download' do

  context 'given a public mega url (a small file)' do

    let(:url) { 'https://mega.nz/file/muAVRRbb#zp9dvPvoVck8-4IwTazqsUqol6yiUK7kwLWOwrD8Jqo' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      related_file = File.join(temp_folder, 'testfile.txt')
      expect(File.read(related_file)).to eq "helloworld!\n"
    end
  end

  context 'given a public mega url (a big file)' do

    let(:url) { 'https://mega.nz/file/3zpE1ToL#B1L4o8POE4tER4h1tyVoGNxaXFhbjwfxhe3Eyp9nrN8' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      related_file = File.join(temp_folder, 'testfile_big_15mb.binary')
      md5 = Digest::MD5.file(related_file).hexdigest
      expect(md5).to eq("a92ec9994911866e3ea31aa1d914ac23")
    end
  end
end
