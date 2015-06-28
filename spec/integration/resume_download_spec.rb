require 'integration_spec_helper'

module Rmega
  describe 'Resumable download' do

    let(:download_url) { 'https://mega.co.nz/#!NYVkDaLD!BKyN5SRpOaEtGnTcwiAqcxmJc7p-k0IPWKAW-471KRE' }

    let(:destination_file) { "#{temp_folder}/temp.txt" }

    before do
      Thread.abort_on_exception = false
      allow_any_instance_of(Pool).to receive(:threads_raises_exceptions).and_return(nil)
    end

    it 'resume a download of a file' do
      node = Nodes::Factory.build_from_url(download_url)
      content = nil

      thread = Thread.new do
        node.download(destination_file)
      end

      loop do
        next unless File.exists?(destination_file)
        node.file_io_synchronize { content = File.read(destination_file) }
        content.strip!
        break if content.size > 5_000_000
        sleep(0.5)
      end

      thread.kill

      sleep(2)

      node.download(destination_file)

      md5 = Digest::MD5.file(destination_file).hexdigest
      expect(md5).to eq("0451dc82ac003dbef703342e40a1b8f6")
    end
  end
end
