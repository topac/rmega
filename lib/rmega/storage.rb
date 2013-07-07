module Rmega
  class Storage

    attr_reader :session

    def initialize session
      @session = session
    end

    def logger
      Rmega.logger
    end


    # Quota-related methods

    def used_space
      quota['cstrg']
    end

    def total_space
      quota['mstrg']
    end

    def quota
      session.request a: 'uq', strg: 1
    end


    # Nodes management

    def nodes
      nodes = session.request a: 'f', c: 1
      nodes['f'].map { |node_data| Node.fabricate(session, node_data) }
    end

    def nodes_by_type type
      nodes.select { |n| n.type == type }
    end

    def nodes_by_name name_regexp
      nodes.select do |node|
        node.name and node.name =~ name_regexp
      end
    end

    def trash_node
      @trash ||= nodes_by_type(:trash).first
    end

    def root_node
      @root_node ||= nodes_by_type(:root).first
    end

    def create_folder parent_node, folder_name
      FolderNode.create session, parent_node, folder_name
    end


    # Handle node download

    def self.chunks size
      list = {}
      p = 0
      pp = 0
      i = 1

      while i <= 8 and p < size - (i * 0x20000)
        list[p] = i * 0x20000
        pp = p
        p += list[p]
        i += 1
      end

      while p < size
        list[p] = 0x100000
        pp = p
        p += list[p]
      end

      if size - pp > 0
        list[pp] = size - pp
      end
      list
    end

    def download public_url, path
      Node.fabricate(session, public_url).download(path)
    end


    # Handle file upload

    def upload_url filesize
      session.request(a: 'u', s: filesize)['p']
    end

    def upload_chunk url, start, chunk
      response = HTTPClient.new.post "#{url}/#{start}", chunk, timeout: Rmega.options.upload_timeout
      response.body
    end

    def upload local_path, parent_node = root_node
      local_path = File.expand_path local_path
      filesize = File.size local_path
      upld_url = upload_url filesize

      ul_key = Crypto.random_key
      aes_key = ul_key[0..3]
      nonce = ul_key[4..5]
      local_file = File.open local_path, 'rb'
      file_handle = nil
      file_mac = [0, 0, 0, 0]

      Utils.show_progress :upload, filesize

      self.class.chunks(filesize).each do |chunk_start, chunk_size|
        buffer = local_file.read chunk_size

        # TODO: should be (chunk_start/0x1000000000) >>> 0, (chunk_start/0x10) >>> 0
        nonce = [nonce[0], nonce[1], (chunk_start/0x1000000000) >> 0, (chunk_start/0x10) >> 0]

        encrypted_buffer = Crypto::AesCtr.encrypt aes_key, nonce, buffer
        chunk_mac = encrypted_buffer[:mac]

        file_handle = upload_chunk upld_url, chunk_start, encrypted_buffer[:data]

        file_mac = [file_mac[0] ^ chunk_mac[0], file_mac[1] ^ chunk_mac[1],
                    file_mac[2] ^ chunk_mac[2], file_mac[3] ^ chunk_mac[3]]
        file_mac = Crypto::Aes.encrypt ul_key[0..3], file_mac
        Utils.show_progress :upload, filesize, chunk_size
      end

      attribs = {n: File.basename(local_path)}
      encrypt_attribs = Utils.a32_to_base64 Crypto.encrypt_attributes(ul_key[0..3], attribs)

      meta_mac = [file_mac[0] ^ file_mac[1], file_mac[2] ^ file_mac[3]]

      key = [ul_key[0] ^ ul_key[4], ul_key[1] ^ ul_key[5], ul_key[2] ^ meta_mac[0],
             ul_key[3] ^ meta_mac[1], ul_key[4], ul_key[5], meta_mac[0], meta_mac[1]]

      encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
      session.request a: 'p', t: parent_node.handle, n: [{h: file_handle, t: 0, a: encrypt_attribs, k: encrypted_key}]

      nil
    ensure
      local_file.close if local_file
    end
  end
end
