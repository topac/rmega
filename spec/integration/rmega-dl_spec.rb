require 'integration_spec_helper'

describe "rmega-dl" do

  let(:url) { 'https://mega.nz/file/muAVRRbb#zp9dvPvoVck8-4IwTazqsUqol6yiUK7kwLWOwrD8Jqo' }

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

  if account?
    context "given an account and a path" do
      it "downloads a file" do
        call("/test_folder/b.txt -u #{account['email']} --pass '#{account['password']}' -o #{temp_folder}")
        downloaded_file = "#{temp_folder}/b.txt"
        expect(File.read(downloaded_file)).to eq "foo\n"
      end
    end
  end
end
