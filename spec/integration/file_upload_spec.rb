require 'integration_spec_helper'

describe 'File upload' do

  if account?

    before(:all) do
      @storage = login
    end

    [12, 6_000, 2_000_000].each do |size|

      context "when a file (#{size} bytes) is uploaded" do

        let(:path) { "#{temp_folder}/testfile_#{SecureRandom.hex(6)}" }

        let(:content) { SecureRandom.random_bytes(size) }

        it 'is found' do
          File.write(path, content)
          file = @storage.root.upload(path)
          file = @storage.root.files.find { |f| f.handle == file.handle }
          file.delete
          expect(file).not_to be_nil
        end
      end
    end
  end
end
