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
        expect(uploaded_folder.folders.first.name).to eq subfolder_empty
        expect(uploaded_folder.folders.last.name).to eq subfolder_with_content
        expect(uploaded_folder.folders.first).to be_empty
        expect(uploaded_folder.folders.last).not_to be_empty
        expect(uploaded_folder.folders.last.files.find { |f| f.name == file1 }).not_to be_nil
        expect(uploaded_folder.folders.last.files.find { |f| f.name == file2 }).not_to be_nil

        uploaded_folder.delete
        expect(uploaded_folder).not_to be_nil
      end
    end
  end
end
