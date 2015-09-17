require 'integration_spec_helper'

describe "rmega-dl" do
  let(:url) { 'https://mega.co.nz/#!MAkg2Iab!bc9Y2U6d93IlRRKVYpcC9hLZjS4G278OPdH6nTFPDNQ' }

  def call(*args)
    `bundle exec ./bin/rmega-dl #{args.join(' ')}`
  end

  context "without args" do

    it "shows the help" do
      expect(call).to match(/usage/i)
    end
  end

  context "given a public link" do
    it "downloads a file" do
      call("'#{url}' -o #{temp_folder}")
      downloaded_file = "#{temp_folder}/testfile.txt"
      expect(File.read(downloaded_file)).to eq "helloworld!\n"
    end
  end

  if account_file_exists?
    context "given an account and a path" do
      it "downloads a file" do
        call("/test_folder/a.txt -u #{account['email']} --pass #{account['password']} -o #{temp_folder}")
        downloaded_file = "#{temp_folder}/a.txt"
        expect(File.read(downloaded_file)).to eq "hello\n"
      end
    end
  end
end
