require 'integration_spec_helper'

describe 'File upload' do

  if account_file_exists?

    before(:all) { @storage = login }

    let(:name) { "test_file" }

    let(:path) { File.join(temp_folder, name)}

    [12, 1_024_000].each do |size|
      context "when a file (#{size} bytes) is uploaded" do

        before do
          File.open(path, 'wb') { |f| f.write(OpenSSL::Random.random_bytes(size)) }
          @file = @storage.root.upload(path)
        end

        it 'it can be found as a file node' do
          found_node = @storage.root.files.find { |f| f.handle == @file.handle }
          expect(found_node).not_to be_nil
        end

        after do
          @file.delete if @file
        end
      end
    end
  end
end
