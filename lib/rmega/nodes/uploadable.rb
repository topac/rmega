require 'rmega/utils'
require 'rmega/pool'
require 'rmega/progress'

module Rmega
  module Nodes
    module Uploadable
      def upload_chunk(base_url, start, buffer)
        size = buffer.length
        stop = start + size - 1
        url = "#{base_url}/#{start}-#{stop}"

        HTTPClient.new.post(url, buffer).body
      end

      def read_chunk(file, start, size)
        file.seek(start)
        file.read(size)
      end

      def encrypt_chunck(rnd_key, file_mac, start, clean_buffer)
        nonce = [rnd_key[4], rnd_key[5], (start/0x1000000000) >> 0, (start/0x10) >> 0]

        encrypted = Crypto::AesCtr.encrypt(rnd_key[0..3], nonce, clean_buffer)
        chunk_mac, data = encrypted[:mac], encrypted[:data]

        file_mac = [file_mac[0] ^ chunk_mac[0], file_mac[1] ^ chunk_mac[1],
                    file_mac[2] ^ chunk_mac[2], file_mac[3] ^ chunk_mac[3]]

        file_mac = Crypto::Aes.encrypt(rnd_key[0..3], file_mac)

        data
      end

      def upload(path)
        path = ::File.expand_path(path)
        filesize = ::File.size(path)
        file = ::File.open(path, 'rb')

        ul_key = Crypto.random_key
        file_mac = [0, 0, 0, 0]
        file_handle = nil
        base_url = upload_url(filesize)

        pool = Pool.new
        read_mutex = Mutex.new

        progress = Progress.new(total: filesize, caption: 'Upload')

        Utils.chunks(filesize).each do |start, size|
          pool.defer do
            encrypted_buffer = nil

            read_mutex.synchronize do
              clean_buffer = read_chunk(file, start, size)
              encrypted_buffer = encrypt_chunck(ul_key, file_mac, start, clean_buffer)
            end

            file_handle = upload_chunk(base_url, start, encrypted_buffer)
            progress.increment(size)
          end
        end

        pool.wait_done

        attribs = {n: ::File.basename(path)}
        encrypt_attribs = Utils.a32_to_base64(Crypto.encrypt_attributes(ul_key[0..3], attribs))

        meta_mac = [file_mac[0] ^ file_mac[1], file_mac[2] ^ file_mac[3]]

        key = [ul_key[0] ^ ul_key[4], ul_key[1] ^ ul_key[5], ul_key[2] ^ meta_mac[0],
               ul_key[3] ^ meta_mac[1], ul_key[4], ul_key[5], meta_mac[0], meta_mac[1]]

        encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
        request(a: 'p', t: handle, n: [{h: file_handle, t: 0, a: encrypt_attribs, k: encrypted_key}])

        attribs[:n]
      ensure
        file.close
      end
    end
  end
end
