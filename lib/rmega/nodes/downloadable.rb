require 'rmega/pool'
require 'rmega/utils'

module Rmega
  module Nodes
    module Downloadable

      # Creates the local file allocating filesize-n bytes (of /dev/zero) for it.
      # Opens the local file to start writing from the beginning of it.
      def allocate(path)
        `dd if=/dev/zero of="#{path}" bs=1 count=0 seek=#{filesize} > /dev/null 2>&1`
        raise "Unable to create file #{path}" if ::File.size(path) != filesize

        ::File.open(path, 'r+b').tap { |f| f.rewind }
      end

      # Downloads a part of the remote file, starting from the start-n byte
      # and ending after size-n bytes.
      def download_chunk(start, size)
        stop = start + size - 1
        url = "#{storage_url}/#{start}-#{stop}"
        HTTPClient.new.get_content(url)
      end

      # Writes a buffer in the local file, starting from the start-n byte.
      def write_chunk(file, start, buffer)
        file.seek(start)
        file.write(buffer)
      end

      def decrypt_chunk(start, encrypted_buffer)
        k = decrypted_file_key
        nonce = [k[4], k[5], (start/0x1000000000) >> 0, (start/0x10) >> 0]
        decrypt_key = [k[0] ^ k[4], k[1] ^ k[5], k[2] ^ k[6], k[3] ^ k[7]]
        Crypto::AesCtr.decrypt(decrypt_key, nonce, encrypted_buffer)[:data]
      end

      def download(path)
        path = ::File.expand_path(path)
        path = Dir.exists?(path) ? ::File.join(path, name) : path

        logger.info "Download #{name} (#{filesize} bytes) => #{path}"

        pool = Pool.new
        write_mutex = Mutex.new
        file = allocate(path)

        progress = Progress.new(total: filesize, caption: 'Download')

        Utils.chunks(filesize).each do |start, size|
          pool.defer do
            encrypted_buffer = download_chunk(start, size)

            write_mutex.synchronize do
              clean_buffer = decrypt_chunk(start, encrypted_buffer)
              progress.increment(size)
              write_chunk(file, start, clean_buffer)
            end
          end
        end

        # waits for the last running threads to finish
        pool.wait_done

        file.flush
      ensure
        file.close rescue nil
      end
    end
  end
end
