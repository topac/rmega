require 'rmega/loggable'
require 'rmega/utils'
require 'rmega/pool'
require 'rmega/progress'

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

      HTTPClient.new.post(url, buffer).body
    end

    def read_chunk(start, size)
      @local_file.seek(start)
      @local_file.read(size)
    end

    def chunks
      Utils.chunks(filesize)
    end

    def upload(&block)
      @local_file = ::File.open(local_path, 'rb')

      progress = Progress.new(total: filesize, caption: 'Upload')

      chunks.each do |start, size|

        pool.defer do
          clean_buffer = pool.synchronize { read_chunk(start, size) }
          encrypted_buffer = yield(start, clean_buffer)
          @last_result = upload_chunk(start, encrypted_buffer)
          progress.increment(clean_buffer.size)
        end
      end

      pool.wait_done
      pool.shutdown
    ensure
      @local_file.close
    end
  end
end
