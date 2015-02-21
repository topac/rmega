module Rmega
  module Nodes
    module Expandable
      include Uploadable

      def create_folder(name)
        node_key = NodeKey.random

        # encrypt attributes
        attributes_str = "MEGA"
        attributes_str << {n: name.strip}.to_json
        attributes_str << ("\x00" * (16 - (attributes_str.size % 16)))
        encrypted_attributes = aes_cbc_encrypt(node_key.aes_key, attributes_str)

        # Encrypt node key
        encrypted_key = aes_ecb_encrypt(session.master_key, node_key.aes_key)

        n = [{h: 'xxxxxxxx', t: 1, a: Utils.base64urlencode(encrypted_attributes), k: Utils.base64urlencode(encrypted_key)}]
        data = session.request(a: 'p', t: handle, n: n)
        return Folder.new(session, data['f'][0])
      end

      def upload_url(filesize)
        session.request(a: 'u', s: filesize)['p']
      end
    end
  end
end
