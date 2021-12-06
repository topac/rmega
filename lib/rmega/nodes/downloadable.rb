module Rmega
  module Nodes
    module Downloadable
      include Net
      include Options

      # Creates the local file allocating filesize-n bytes (of /dev/zero) for it.
      # Opens the local file to start writing from the beginning of it.
      def allocate(path)
        unless allocated?(path)
          `dd if=/dev/zero of="#{path}" bs=1 count=0 seek=#{filesize} > /dev/null 2>&1`
          raise "Unable to allocate space for file #{path}" if ::File.size(path) != filesize
        end

        @file = ::File.open(path, 'r+b')
        @file.rewind
      end

      def file_io_synchronize(&block)
        @file_io_mutex ||= Mutex.new
        @file_io_mutex.synchronize(&block)
      end

      def allocated?(path)
        ::File.exists?(path) and ::File.size(path) == filesize
      end

      # Writes a buffer in the local file, starting from the start-n byte.
      def write_chunk(start, buffer)
        file_io_synchronize do
          @file.seek(start)
          @file.write(buffer)
        end
      end

      def read_chunk(start, size)
        file_io_synchronize do
          @file.seek(start)
          data = @file.read(size)
          @file.seek(start)
          return (data == "\x0"*size) ? nil : data
        end
      end

      # Downloads a part of the remote file, starting from the start-n byte
      # and ending after size-n bytes.
      def download_chunk(start, size)
        stop = start + size - 1
        url = "#{storage_url}/#{start}-#{stop}"

        survive do
          data = http_get_content(url)
          raise("Unexpected data length") if data.size != size
          return data
        end
      end

      def decrypt_chunk(start, data)
        iv = @node_key.ctr_nonce + [start/0x1000000000, start/0x10].pack('l>*')
        return aes_ctr_decrypt(@node_key.aes_key, data, iv)
      end

      def calculate_chunck_mac(data)
        mac_iv = @node_key.ctr_nonce * 2
        return aes_cbc_mac(@node_key.aes_key, data, mac_iv)
      end

      def download(path)
        path = ::File.expand_path(path)
        path = Dir.exists?(path) ? ::File.join(path, name) : path

        progress = Progress.new(filesize, caption: 'Allocate', filename: self.name)
        pool = Pool.new

        @resumed_download = allocated?(path)
        allocate(path)
        @node_key = NodeKey.load(decrypted_file_key)

        chunk_macs = {}

        each_chunk do |start, size|
          pool.process do
            data = @resumed_download ? read_chunk(start, size) : nil

            if data
              chunk_macs[start] = calculate_chunck_mac(data) if options.file_integrity_check
              progress.increment(size, real: false, caption: "Verify")
            else
              data = decrypt_chunk(start, download_chunk(start, size))
              chunk_macs[start] = calculate_chunck_mac(data) if options.file_integrity_check
              write_chunk(start, data)
              progress.increment(size, caption: "Download")
            end
          end
        end

        # waits for the last running threads to finish
        pool.wait_done

        if options.file_integrity_check
          file_mac = aes_cbc_mac(@node_key.aes_key, chunk_macs.sort.map(&:last).join, "\x0"*16)

          if Utils.compact_to_8_bytes(file_mac) != @node_key.meta_mac
            raise("Checksum failed. File corrupted?")
          end
        end

        return nil
      ensure
        @file.close rescue nil
      end
    end
  end
end
