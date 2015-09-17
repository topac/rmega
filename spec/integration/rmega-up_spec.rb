require 'integration_spec_helper'
require 'open3'

describe "rmega-up" do
  def call(*args)
    Open3.capture2e("bundle exec ./bin/rmega-up #{args.join(' ')}").join("\n")
  end

  let(:file_content) { SecureRandom.hex(10) }

  let(:filename) { "testfile_"+SecureRandom.hex(5)+".txt" }

  let(:filepath) { "#{temp_folder}/#{filename}" }

  before do
    File.write(filepath, file_content)
  end

  context "without args" do

    it "shows the help" do
      expect(call).to match(/usage/i)
    end
  end

  context "without username" do
    it "fails" do
      expect(call(filepath)).to match(/require/i)
    end
  end

  context "when the local file is missing" do
    it "fails" do
      expect(call("foobar.txt")).to match(/missing|not found/i)
    end
  end

  if account_file_exists?
    context "when the remote path is missing" do
      it "fails" do
        resp = call("#{filepath} -u #{account['email']} --pass #{account['password']} -r /foobar")
        expect(resp).to match(/error/i)
      end
    end

    context "without specifying a remote folder" do
      it "uploads a file to the root node" do
        call("#{filepath} -u #{account['email']} --pass #{account['password']}")
        storage = login
        node = storage.root.files.find { |f| f.name == filename }
        node.delete if node
        expect(node).not_to be_nil
      end
    end

    context "when specifying a remote folder" do
      it "uploads a file into that folder" do
        call("#{filepath} -u #{account['email']} --pass #{account['password']} -r test_folder2")
        storage = login
        node = storage.root.folders.find { |f| f.name == "test_folder2" }
        node = node.files.find { |f| f.name == filename }
        node.delete if node
        expect(node).not_to be_nil
      end
    end
  end
end
