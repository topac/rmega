module Rmega
  module Nodes
    module Uploadable
      include Net

      def upload_chunk(base_url, start, buffer)
        size = buffer.length
        stop = start + size - 1
        url = "#{base_url}/#{start}-#{stop}"

        survive do
          response = http_post(url, buffer)
          raise("Upload failed") if response.code.to_i != 200
          return response.body
        end
      end

      def read_chunk(file, start, size)
        file.seek(start)
        file.read(size)
      end

      def encrypt_chunck(start, clean_buffer, aes_key, nonce)
        iv = nonce + [start/0x1000000000, start/0x10].pack('l>*')
        enc_data = aes_ctr_encrypt(aes_key, clean_buffer, iv)

        # calculate mac
        mac_iv = nonce * 2
        mac = aes_cbc_mac(aes_key, clean_buffer, mac_iv)

        return [enc_data, mac]
      end

      def upload(path)
        path = ::File.expand_path(path)
        filesize = ::File.size(path)

        raise "Empty file - #{path}" if filesize == 0

        file = ::File.open(path, 'rb')

        rnd_node_key = NodeKey.random
        file_handle = nil
        base_url = upload_url(filesize)

        pool = Pool.new
        read_mutex = Mutex.new

        progress = Progress.new(filesize, caption: 'Upload', filename: ::File.basename(path))

        chunk_macs = {}

        self.class.each_chunk(filesize) do |start, size|
          pool.process do
            clean_buffer = nil

            read_mutex.synchronize do
              clean_buffer = read_chunk(file, start, size)
            end

            encrypted_buffer, chunk_mac = *encrypt_chunck(start, clean_buffer, rnd_node_key.aes_key, rnd_node_key.ctr_nonce)
            file_handle = upload_chunk(base_url, start, encrypted_buffer)
            chunk_macs[start] = chunk_mac

            progress.increment(size)
          end
        end

        pool.wait_done

        # encrypt attributes
        _attr = serialize_attributes(:n => Utils.utf8(::File.basename(path)))
        _attr = aes_cbc_encrypt(rnd_node_key.aes_key, _attr)

        # Calculate meta_mac
        file_mac = aes_cbc_mac(rnd_node_key.aes_key, chunk_macs.sort.map(&:last).join, "\x0"*16)
        rnd_node_key.meta_mac = Utils.compact_to_8_bytes(file_mac)
        encrypted_key = aes_ecb_encrypt(session.master_key, rnd_node_key.generate)

        resp = request(a: 'p', t: handle, n: [
          {h: file_handle, t: 0, a: Utils.base64urlencode(_attr), k: Utils.base64urlencode(encrypted_key)}
        ])

        return Nodes::Factory.build(session, resp['f'][0])
      ensure
        file.close if file
      end
    end
  end
end
