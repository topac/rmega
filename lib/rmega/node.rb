module Rmega
  class Node
    attr_reader :data, :session

    def initialize data
      @session = self.class.session
      @data = data
    end

    def self.session
      Rmega.current_session
    end

    def self.types
      {file: 0, dir: 1, root: 2, inbox: 3, trash: 4}
    end


    # Finders

    def self.all
      nodes = session.request a: 'f', c: 1
      nodes['f'].map { |node_data| new(node_data) }
    end

    def self.find_all_by_type type
      all.select { |n| n.type == type }
    end

    def self.find_all_by_name name_regexp
      all.select do |node|
        node.name and node.name =~ name_regexp
      end
    end

    def self.find_trash
      find_all_by_type(:trash).first
    end


    # Member action

    def public_url
      return nil if type != :file
      b64_dec_key = Utils.a32_to_base64 decrypted_file_key[0..7]
      "https://mega.co.nz/#!#{public_handle}!#{b64_dec_key}"
    end

    def move_to_trash
      @trash_node ||= self.class.find_trash
      session.request a: 'm', n: handle, t: @trash_node.handle
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
      Crypto.decrypt_key session.master_key, Utils.base64_to_a32(file_key)
    end

    def decrypt_attributes
      a32key = decrypted_file_key
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes = Crypto::Aes.decrypt a32key, Utils.base64_to_a32(data['a'])
      attributes = Utils.a32_to_str attributes
      JSON.parse attributes.gsub(/^MEGA/, '').rstrip
    end

    def owned_by_me?
      data['u'] == owner_key
    end

    def attributes
      @attributes ||= begin
        decrypt_attributes if owned_by_me?
      end
    end

    def type
      founded_type = self.class.types.find { |k, v| data['t'] == v }
      founded_type.first if founded_type
    end

    def storage_url
      @storage_url ||= session.request(a: 'g', g: 1, n: handle)
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
        i += 1
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

    def download
      k = decrypted_file_key
      k = [k[0] ^ k[4], k[1] ^ k[5], k[2] ^ k[6], k[3] ^ k[7]]
      iv = decrypted_file_key[4..5] + [0, 0]

      ctr_init = ((iv[0] << 32) + iv[1]) << 64
      ctr_incr = 128

      cipher = Crypto::AesCtrCipher.new k, iv

      connection = HTTPClient.new.get_async storage_url
      message = connection.pop

      # Thread.new do
      chunks.each do |chunk_start, chunk_size|
        buffer = message.content.read(chunk_size)
        # buffer = cipher.decrypt buffer
        puts buffer
      end
      # end
    end

  end
end
