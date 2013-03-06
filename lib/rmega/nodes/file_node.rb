module Rmega
  class FileNode < Node
    def storage_url
      @storage_url ||= data['g'] || request(a: 'g', g: 1, n: handle)['g']
    end

    def chunks
      Storage.chunks filesize
    end

    def download path
      path = File.expand_path path
      path = Dir.exists?(path) ? File.join(path, name) : path

      logger.info "Starting download into #{path}"

      Utils.show_progress :download, filesize

      k = decrypted_file_key
      k = [k[0] ^ k[4], k[1] ^ k[5], k[2] ^ k[6], k[3] ^ k[7]]
      nonce = decrypted_file_key[4..5]

      file = File.open path, 'wb'
      connection = HTTPClient.new.get_async storage_url
      message = connection.pop

      chunks.each do |chunk_start, chunk_size|
        buffer = message.content.read chunk_size
        # TODO: should be (chunk_start/0x1000000000) >>> 0, (chunk_start/0x10) >>> 0
        nonce = [nonce[0], nonce[1], (chunk_start/0x1000000000) >> 0, (chunk_start/0x10) >> 0]
        decryption_result = Crypto::AesCtr.decrypt(k, nonce, buffer)
        file.write(decryption_result[:data])
        Utils.show_progress :download, filesize, chunk_size
      end

      nil
    ensure
      file.close if file
    end
  end
end
