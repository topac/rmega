require 'rmega/loggable'
require 'rmega/utils'
require 'rmega/pool'

module Rmega
  class Uploader
    include Loggable

    attr_reader :pool, :base_url, :filesize, :local_path, :last_result

    def initialize(params)
      @pool = Pool.new(params[:threads])
      @filesize = params[:filesize]
      @base_url = params[:base_url]
      @local_path = params[:local_path]
      @last_result = nil
    end

    def upload_chunk(start, buffer)
      size = buffer.length
      stop = start + size - 1
      url = "#{base_url}/#{start}-#{stop}"
      # puts "#{Thread.current} uploading chunk @ #{start}"
      HTTPClient.new.post(url, buffer).body
    end

    def read_chunk(start, size)
      # puts "#{Thread.current} reading chunk @ #{start}"
      @local_file.seek(start)
      @local_file.read(size)
    end

    # Shows the progress bar in console
    def show_progress(increment)
      Utils.show_progress(:upload, filesize, increment)
    end

    def chunks
      Utils.chunks(filesize)
    end

    # TODO: checksum check
    def upload(&block)
      @local_file = ::File.open(local_path, 'rb')

      show_progress(0)

      chunks.each do |start, size|
        buffer = read_chunk(start, size)

        pool.defer do
          encrypted_buffer = yield(start, buffer)
          @last_result = upload_chunk(start, encrypted_buffer)
          show_progress(buffer.size)
        end
      end

      pool.wait_done
      pool.shutdown
    ensure
      @local_file.close
    end
  end
end
