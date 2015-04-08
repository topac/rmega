require 'integration_spec_helper'

describe 'Folder download' do

  context 'given a public mega url (folder)' do

    let(:url) { 'https://mega.co.nz/#F!IYERlQqa!pvqkX7UUsRGKBs3FWKXzUQ' }

    it 'downloads the related file' do
      Rmega.download(url, temp_folder)
      list = Dir["#{temp_folder}/test_folder/**/*"].map do |p|
        p.gsub("#{temp_folder}/test_folder/", "")
      end
      expect(list.sort).to eq(["a.txt", "b.txt", "c", "c/c.txt"])
    end
  end
end
