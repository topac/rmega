require 'integration_spec_helper'

describe 'Folder upload' do

  if account?

    before(:all) do
      @storage = login
    end

    context "when a folder is uploaded" do

      let(:folder) { SecureRandom.hex(6) }
      let(:subfolder_empty) { SecureRandom.hex(6) }
      let(:subfolder_with_content) { SecureRandom.hex(6) }
      let(:file1) { SecureRandom.hex(6) }
      let(:file2) { SecureRandom.hex(6) }

      it 'all its content is found' do
        Dir.mkdir("#{temp_folder}/#{folder}")
        Dir.mkdir("#{temp_folder}/#{folder}/#{subfolder_empty}")
        Dir.mkdir("#{temp_folder}/#{folder}/#{subfolder_with_content}")
        File.write("#{temp_folder}/#{folder}/#{subfolder_with_content}/#{file1}", SecureRandom.random_bytes(1000))
        File.write("#{temp_folder}/#{folder}/#{subfolder_with_content}/#{file2}", SecureRandom.random_bytes(2000))

        @storage.root.upload_dir("#{temp_folder}/#{folder}")

        uploaded_folder = @storage.root.folders.find { |f| f.name == folder }

        expect(uploaded_folder.folders.size).to eq 2
        folder1 = uploaded_folder.folders.find {|f| f.name == subfolder_empty}
        folder2 = uploaded_folder.folders.find {|f| f.name == subfolder_with_content}
        
        expect(folder1).not_to be_nil
        expect(folder2).not_to be_nil
        
        expect(folder1.folders).to be_empty
        expect(folder1.files).to be_empty
        
        expect(folder2.folders).to be_empty
        expect(folder2.files.find { |f| f.name == file1 }).not_to be_nil
        expect(folder2.files.find { |f| f.name == file2 }).not_to be_nil

        uploaded_folder.delete
      end
    end
  end
end
