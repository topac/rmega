require 'integration_spec_helper'

describe 'Folder download' do

  context 'given a public mega url (folder)' do

    let(:url) { 'https://mega.nz/folder/GvgkUIIK#v2hd_5GSvciGKazNeWSa6A' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      list = Dir["#{temp_folder}/another_test_folder/**/*"].map do |p|
        p.gsub("#{temp_folder}/another_test_folder/", "")
      end
      expect(list.sort).to eq(["b.txt", "c", "c/c.txt"])
    end
  end
end
