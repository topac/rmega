require 'integration_spec_helper'
require 'fileutils'

describe 'File upload' do

  if account_file_exists?

    before(:all) { @storage = login }

    # context 'upload a small file to the root folder' do

    #   before(:all) do
    #     @name = "i_like_trains_#{rand(1E20)}"
    #     @content = @name
    #   end

    #   def find_file
    #     @storage.root.files.find { |f| f.name == @name }
    #   end

    #   let(:path) { File.join(temp_folder, @name) }

    #   before do
    #     File.open(path, 'wb') { |f| f.write(@content) }
    #     @storage.root.upload(path)
    #   end

    #   it 'finds the uploaded file' do
    #     file = find_file
    #     file.delete
    #     expect(file).not_to be_nil
    #   end

    #   context 'download the same file' do

    #     let(:download_path) { "#{path}.downloaded" }

    #     before do
    #       file = find_file
    #       file.download(download_path)
    #       file.delete
    #     end

    #     it 'has the expected @content' do
    #       expect(File.read(download_path)).to eql @content
    #     end
    #   end
    # end

    context 'upload a big file to a specific folder' do

      before(:all) do
        @name = "mine_turtles_#{rand(1E20)}"
        @path = File.join(temp_folder, @name)
        @buffer = "rofl" * 1024

        File.open(@path, 'wb') do |f|
          512.times { f.write(@buffer) }
        end
      end

      let!(:folder) { @storage.root.create_folder(@name) }

      before(:all) { folder.upload(@path) }

      it 'finds the uploaded file and verify its content' do
        file = folder.files.find { |f| f.name == @name }
        download_path = "#{@path}.downloaded"
        file.download(download_path)

        File.open(download_path, 'rb') do |f|
          512.times { expect(f.read(@buffer.size)).to eq(@buffer) }
        end
      end

      after { folder.delete }
    end
  end
end
