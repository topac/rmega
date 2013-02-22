module Rmega
  class Storage

    attr_reader :session

    def initialize session
      @session = session
    end


    # Nodes finders

    def nodes
      nodes = session.request a: 'f', c: 1
      nodes['f'].map { |node_data| Node.new(session, node_data) }
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


    # Handle node download

    def download public_url, path
      Node.initialize_by_public_url(session, public_url).download path
    end


    # Handle file upload

    def upload_url filesize
      session.request(a: 'u', s: filesize)['p']
    end

    def upload_chunk url, start, chunk
      response = HTTPClient.new.post "#{url/start}", chunk
    end

    def upload local_path
      filesize = File.size local_path
      upld_url = upload_url filesize

      ul_key = Array.new(6).map { rand(0..0xFFFFFFFF) }
      aes_key = ul_key[0..3]
      nonce = ul_key[4..5]
      local_file = File.open local_path, 'rb'

      Node.chunks(filesize).each do |chunk_start, chunk_size|
        buffer = local_file.read chunk_size
        encrypted_buffer = AesCtr.encrypt aes_key, nonce, buffer
        # upload_chunk upld_url, chunk_start, encrypted_buffer[:data]
      end
    ensure
      local_file.close if local_file
    end
  end
end
