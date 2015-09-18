require 'integration_spec_helper'

describe 'File integrity' do

  if account?

    before(:all) do
      @storage = login
    end

    context "when a file is renamed" do

      let(:path) { "#{temp_folder}/testfile_#{SecureRandom.hex(6)}" }

      let(:new_name) { "testfile_#{SecureRandom.hex(6)}" }

      it 'it does not get corrupted' do
        File.write(path, SecureRandom.hex(24))
        file = @storage.root.upload(path)
        file.rename(new_name)
        expect(file.name).to eq(new_name)
        file = @storage.nodes.find { |n| n.handle == file.handle }
        file.delete
        expect(file.name).to eq(new_name)
      end
    end

    [12, 6_000].each do |size|

      context "when a file (#{size} bytes) is uploaded and then downloaded" do

        let(:path) { "#{temp_folder}/testfile_#{SecureRandom.hex(6)}" }

        let(:content) { SecureRandom.random_bytes(size) }

        let(:content_hash) { Digest::MD5.hexdigest(content) }

        it 'it does not get corrupted' do
          File.write(path, content)
          file = @storage.root.upload(path)
          file.download("#{path}.downloaded")
          file.delete
          expect(Digest::MD5.file("#{path}.downloaded").hexdigest).to eq(content_hash)
        end
      end
    end
  end
end
