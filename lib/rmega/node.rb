module Rmega
  class Node
    attr_reader :data, :session

    def initialize session, data
      @session = session
      @data = data
    end

    def self.initialize_by_public_url session, public_url
      public_handle, key = public_url.split('!')[1, 2]
      data = session.request a: 'g', g: 1, p: public_handle
      node = new session, data
      node.instance_variable_set '@public_url', public_url
      node
    end

    def self.types
      {file: 0, dir: 1, root: 2, inbox: 3, trash: 4}
    end


    # Member actions

    def public_url
      return @public_url if @public_url
      return nil if type != :file
      b64_dec_key = Utils.a32_to_base64 decrypted_file_key[0..7]
      "https://mega.co.nz/#!#{public_handle}!#{b64_dec_key}"
    end

    def trash
      trash_node_public_handle = session.storage.trash_node.public_handle
      session.request a: 'm', n: handle, t: trash_node_public_handle
    end


    # Other methods

    def public_handle
      @public_handle ||= session.request(a: 'l', n: handle)
    end

    def handle
      data['h']
    end

    def filesize
      data['s']
    end

    def owner_key
      data['k'].split(':').first
    end

    def name
      return attributes['n'] if attributes
    end

    def file_key
      data['k'].split(':').last
    end

    def decrypted_file_key
      if data['k']
        Crypto.decrypt_key session.master_key, Utils.base64_to_a32(file_key)
      else
        Utils.base64_to_a32 public_url.split('!').last
      end
    end

    def decrypt_attributes
      a32key = decrypted_file_key
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes = Crypto::Aes.decrypt a32key, Utils.base64_to_a32(data['a'] || data['at'])
      attributes = Utils.a32_to_str attributes
      JSON.parse attributes.gsub(/^MEGA/, '').rstrip
    end

    def can_decrypt_attributes?
      !data['u'] or data['u'] == owner_key
    end

    def attributes
      @attributes ||= decrypt_attributes if can_decrypt_attributes?
    end

    def type
      founded_type = self.class.types.find { |k, v| data['t'] == v }
      founded_type.first if founded_type
    end

    def storage_url
      @storage_url ||= data['g'] || session.request(a: 'g', g: 1, n: handle)['g']
    end

    def chunks
      list = {}
      p = 0
      pp = 0
      i = 1

      while i <= 8 and p < filesize - i * 0x20000
        list[p] = i * 0x20000
        pp = p
        p += list[p]
        i += 128
      end

      while p < filesize
        list[p] = 0x100000
        pp = p
        p += list[p]
      end

      if filesize - pp > 0
        list[pp] = filesize - pp
      end
      list
    end

    def show_progress direction, total, increment = 0
      return unless Rmega.options.show_progress
      @progressbar.progress += increment if @progressbar
      current_progress = @progressbar.progress if @progressbar
      format = "#{direction.to_s.capitalize} in progress #{Utils.format_bytes(current_progress || 0)} of #{Utils.format_bytes(total)} | %P% | %e        "
      if !@progressbar or (@progressbar and increment.zero?)
        @progressbar = ProgressBar.create format: format, total: total
      end
      @progressbar.format format
    end

    def download path
      path = File.expand_path path
      path = Dir.exists?(path) ? File.join(path, name) : path

      show_progress :download, filesize

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
        file.write(decryption_result[:plain])
        show_progress :download, filesize, chunk_size
      end

      nil
    ensure
      file.close if file
    end
  end
end
