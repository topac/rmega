require 'integration_spec_helper'

module Rmega
  describe 'Resumable download' do

    let(:download_url) { 'https://mega.nz/file/3zpE1ToL#B1L4o8POE4tER4h1tyVoGNxaXFhbjwfxhe3Eyp9nrN8' }

    let(:destination_file) { "#{temp_folder}/temp.txt" }

    before do
      Thread.abort_on_exception = false if Thread.respond_to?(:abort_on_exception)
      Thread.report_on_exception = false if Thread.respond_to?(:report_on_exception)
      allow_any_instance_of(Pool).to receive(:threads_raises_exceptions).and_return(nil)
    end

    it 'resume a download of a file' do
      node = Nodes::Factory.build_from_url(download_url)
      
      thread = Thread.new do
        node.download(destination_file)
      end
      
      loop do
        next unless File.exist?(destination_file)
        content = nil
        node.file_io_synchronize { content = File.read(destination_file) }
        break if content.force_encoding("BINARY").strip.size > 2_000_000
        sleep(0.1)
      end

      thread.kill

      sleep(2)

      node.download(destination_file)

      md5 = Digest::MD5.file(destination_file).hexdigest
      expect(md5).to eq("a92ec9994911866e3ea31aa1d914ac23")
    end
  end
end
