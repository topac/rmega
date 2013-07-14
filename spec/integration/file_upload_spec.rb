require 'integration_spec_helper'
require 'fileutils'

describe 'File download' do

  if account_file_exists?

    let(:storage) { login }

    context 'Upload a small file to the root folder' do

      let(:content) { "I like trains\n#{rand(1E20)}" }

      let(:name) { "i_like_trains.txt" }

      let(:path) { File.join(temp_folder, name) }

      before do
        File.open(path, 'wb') { |f| f.write(content) }
        storage.root.upload(path)
      end

      it 'finds the uploaded file' do
        file = storage.root.files.find { |f| f.name == name }
        expect(file).not_to be_nil
      end
    end
  end
end
