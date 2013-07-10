module Rmega
  class Downloader
    include Loggable

    attr_reader :pool, :base_url, :filesize, :local_path

    def initialize(params)
      @pool = Thread.pool(params[:threads] || 5)
      @filesize = params[:filesize]
      @base_url = params[:base_url]
      @local_path = params[:local_path]
    end

    # Creates the local file allocating filesize-n bytes (of /dev/zero) for it.
    # Opens the local file to start writing from the beginning of it.
    def allocate
      `dd if=/dev/zero of="#{local_path}" bs=1 count=0 seek=#{filesize} > /dev/null 2>&1`
      raise "Unable to create file #{local_path}" if File.size(local_path) != filesize

      File.open(local_path, 'r+b').tap { |f| f.rewind }
    end

    # Downloads a part of the remote file, starting from the start-n byte
    # and ending after size-n bytes.
    def download_chunk(start, size)
      stop = start + size - 1
      url = "#{base_url}/#{start}-#{stop}"
      # logger.debug "#{Thread.current} downloading chunk @ #{start}"
      HTTPClient.new.get_content(url)
    end

    # Writes a buffer in the local file, starting from the start-n byte.
    def write_chunk(start, buffer)
      # logger.debug "#{Thread.current} writing chunk @ #{position}"
      @local_file.seek(start)
      @local_file.write(buffer)
    end

    # Shows the progress bar in console
    def show_progress(increment)
      Utils.show_progress(:download, filesize, increment)
    end

    def chunks
      Storage.chunks(filesize)
    end

    # TODO: checksum check
    def download(&block)
      @local_file = allocate

      show_progress(0)

      chunks.each do |start, size|
        pool.defer do
          buffer = download_chunk(start, size)
          buffer = yield(start, buffer) if block_given?
          show_progress(size)
          pool.synchronize { write_chunk(start, buffer) }
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
