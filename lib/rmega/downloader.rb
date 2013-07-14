require 'rmega/loggable'
require 'rmega/utils'
require 'rmega/pool'
require 'rmega/progress'

module Rmega
  class Downloader
    include Loggable

    attr_reader :pool, :base_url, :filesize, :local_path

    def initialize(params)
      @pool = Pool.new(params[:threads])
      @filesize = params[:filesize]
      @base_url = params[:base_url]
      @local_path = params[:local_path]
    end

    # Creates the local file allocating filesize-n bytes (of /dev/zero) for it.
    # Opens the local file to start writing from the beginning of it.
    def allocate
      `dd if=/dev/zero of="#{local_path}" bs=1 count=0 seek=#{filesize} > /dev/null 2>&1`
      raise "Unable to create file #{local_path}" if File.size(local_path) != filesize

      ::File.open(local_path, 'r+b').tap { |f| f.rewind }
    end

    # Downloads a part of the remote file, starting from the start-n byte
    # and ending after size-n bytes.
    def download_chunk(start, size)
      stop = start + size - 1
      url = "#{base_url}/#{start}-#{stop}"
      HTTPClient.new.get_content(url)
    end

    # Writes a buffer in the local file, starting from the start-n byte.
    def write_chunk(start, buffer)
      @local_file.seek(start)
      @local_file.write(buffer)
    end

    def chunks
      Utils.chunks(filesize)
    end

    def download(&block)
      @local_file = allocate

      progress = Progress.new(total: filesize, caption: 'Download')

      chunks.each do |start, size|
        pool.defer do
          encrypted_buffer = download_chunk(start, size)
          clean_buffer = yield(start, encrypted_buffer)
          progress.increment(size)
          pool.synchronize { write_chunk(start, clean_buffer) }
        end
      end

      # waits for the last running threads to finish
      pool.wait_done

      @local_file.flush

      pool.shutdown
    ensure
      @local_file.close rescue nil
    end
  end
end
