require 'integration_spec_helper'

describe 'Folders operations' do

  if account_file_exists?

    before(:all) do
      @name = "test_folder_#{rand.denominator}_#{rand.denominator}"
      @storage = login
    end

    def find_folder
      @storage.root.folders.find { |f| f.name == @name }
    end

    context 'when #create_folder is called on a node' do

      it 'creates a new folder under that node' do
        folder = @storage.root.create_folder(@name)
        expect(folder.name).to eql @name
      end
    end

    context 'searching for a folder by its name' do

      it 'returns the matching folder' do
        expect(find_folder.name).to eql @name
      end
    end

    context 'when #delete is called on a folder node' do

      it 'deletes the folder' do
        expect(find_folder.delete).to eql 0
      end

      it 'does not find the folder anymore' do
        expect(find_folder).to be_nil
      end
    end
  end
end
