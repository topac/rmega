module Rmega
  class FileNode < Node
    def storage_url
      @storage_url ||= data['g'] || request(a: 'g', g: 1, n: handle)['g']
    end

    def chunks
      Storage.chunks filesize
    end

    def download_chunk(key, nonce, chunk_start, chunk_size)
      download_chunk_url = "#{storage_url}/#{chunk_start}-#{chunk_start+chunk_size}"

      print "#{Thread.current} download_chunk: #{chunk_start}-#{chunk_start+chunk_size}\n"

      buffer = HTTPClient.new.get_content(download_chunk_url)

      # TODO: should be (chunk_start/0x1000000000) >>> 0, (chunk_start/0x10) >>> 0
      decryption_result = Crypto::AesCtr.decrypt(key, nonce, buffer)
      # Utils.show_progress :download, filesize, chunk_size

      @download_pool.synchronize do
        puts "#{Thread.current} Writing chunk #{chunk_start}"
        @local_file.seek(chunk_start)
        @local_file.write(decryption_result[:data])
        @local_file.flush
      end
    end

    def create_empty_file(path, filesize)
      `dd if=/dev/zero of="#{path}" bs=1 count=0 seek=#{filesize} > /dev/null 2>&1`
      raise "Unable to create file #{File.basename(path)}" if File.size(path) != filesize
    end

    def download(path)
      path = File.expand_path path
      path = Dir.exists?(path) ? File.join(path, name) : path

      logger.info "Starting download into #{path}"

      # Utils.show_progress :download, filesize

      k = decrypted_file_key
      k = [k[0] ^ k[4], k[1] ^ k[5], k[2] ^ k[6], k[3] ^ k[7]]
      nonce = decrypted_file_key[4..5]

      @download_pool = Thread.blocking_pool(5)

      create_empty_file(path, filesize)
      @local_file = File.open(path, 'r+b')
      @local_file.rewind
      @local_file_next_chunk = 0

      chunks.each do |chunk_start, chunk_size|
        @download_pool.defer do
          nonce = [nonce[0], nonce[1], (chunk_start/0x1000000000) >> 0, (chunk_start/0x10) >> 0]
          download_chunk(k, nonce, chunk_start, chunk_size)
        end
      end

      # wait for the last running threads to finish
      sleep 0.01 until @download_pool.done?

      @download_pool.shutdown

      nil
    ensure
      @local_file.close if @local_file
    end
  end
end
