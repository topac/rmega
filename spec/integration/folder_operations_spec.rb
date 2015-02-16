require 'integration_spec_helper'

describe 'Folders operations' do

  if account_file_exists?

    before(:all) do
      @name = "folder_#{rand.denominator}_#{rand.denominator}"
      @sub_folder_name = "folder_#{rand.denominator}_#{rand.denominator}"
      @storage = login
    end

    # Note: node searching is traversal
    def find_folder(name)
      @storage.nodes.find { |f| f.type == :folder && f.name == name }
    end

    context 'when #create_folder is called on a node' do

      it 'creates a new folder under that node' do
        folder = @storage.root.create_folder(@name)
        expect(folder.name).to eql @name
        expect(folder.parent_handle).to eq @storage.root.handle
      end
    end

    context 'searching for a folder by its name' do

      it 'returns the matching folder' do
        expect(find_folder(@name).name).to eql @name
      end
    end

    context "when #create_folder under created folder" do

      it "creates a new folder under created folder" do
        parent_folder = find_folder(@name)

        sub_folder = parent_folder.create_folder(@sub_folder_name)

        expect(parent_folder.folders.first.name).to eql @sub_folder_name
        expect(sub_folder.parent_handle).to eql parent_folder.handle
      end
    end

    context 'when #delete is called on a folder node' do

      it 'deletes sub folder' do
        expect(find_folder(@sub_folder_name).delete).to eql 0
      end

      # todo: i see this failing a couple of times
      it 'deletes the folder' do
        expect(find_folder(@name).delete).to eql 0
      end

      it 'does not find the folder (and its subfolder) anymore' do
        expect(find_folder(@name)).to be_nil
        expect(find_folder(@sub_folder_name)).to be_nil
      end
    end
  end
end
