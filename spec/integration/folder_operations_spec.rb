require 'integration_spec_helper'

describe 'Folders operations' do

  if account?

    before(:all) do
      @storage = login
    end

    context 'when #create_folder is called on a node' do

      let(:name) { "testfolder_#{SecureRandom.hex(5)}" }

      before do
        @folder = @storage.root.create_folder(name)
      end

      it 'creates a new folder under that node' do
        expect(@folder.name).to eql name
        expect(@folder.parent_handle).to eq @storage.root.handle
      end

      after do
        @folder.delete
      end
    end

    context 'searching for a folder by its handle' do

      let(:name) { "testfolder_#{SecureRandom.hex(5)}" }

      before do
        @folder = @storage.root.create_folder(name)
      end

      it 'returns the matching folder' do
        found_node = @storage.nodes.find { |n| n.handle == @folder.handle }
        expect(found_node).not_to be_nil
      end

      after do
        @folder.delete
      end
    end

    context 'when #create_folder under created folder' do

      let(:name) { "testfolder_#{SecureRandom.hex(5)}" }

      before do
        @folder = @storage.root.create_folder(name)
        @sub_folder = @folder.create_folder(name)
      end

      it 'creates a new folder under created folder' do
        found_node = @storage.nodes.find { |n| n.handle == @sub_folder.handle }
        expect(found_node.parent_handle).to eq(@folder.handle)
      end

      after do
        @folder.delete
        found_node = @storage.nodes.find { |n| n.handle == @sub_folder.handle }
        expect(found_node).to be_nil
      end
    end
  end
end
