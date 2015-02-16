require 'integration_spec_helper'

describe 'File integrity over upload/download operations' do

  if account_file_exists?

    before(:all) do
      @storage = login
    end

    let(:name) { "test_file" }

    let(:path) { File.join(temp_folder, name)}

    [12, 1_024_000].each do |size|

      context "when a file (#{size} bytes) is uploaded and then downloaded" do

        let(:content) { OpenSSL::Random.random_bytes(size) }

        let(:content_hash) { Digest::MD5.hexdigest(content) }

        before do
          File.open(path, 'wb') { |f| f.write(content) }
          file = @storage.root.upload(path)
          @file = @storage.nodes.find { |n| n.handle == file.handle }
          expect(@file.name).to eq(name)
          @file.download(path+".downloaded")
        end

        it 'it does not get corrupted' do
          expect(Digest::MD5.file(path+".downloaded").hexdigest).to eq(content_hash)
        end

        after do
          @file.delete if @file
        end
      end
    end
  end
end
