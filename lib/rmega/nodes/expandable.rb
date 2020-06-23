module Rmega
  module Nodes
    module Expandable
      include Uploadable

      def create_folder(name)
        node_key = NodeKey.random

        # encrypt attributes
        _attr = serialize_attributes(:n => Utils.utf8(name).strip)
        _attr = aes_cbc_encrypt(node_key.aes_key, _attr)

        # Encrypt node key
        encrypted_key = aes_ecb_encrypt(session.master_key, node_key.aes_key)

        n = [{h: 'xxxxxxxx', t: 1, a: Utils.base64urlencode(_attr), k: Utils.base64urlencode(encrypted_key)}]
        data = session.request(a: 'p', t: handle, n: n)
        return Folder.new(session, data['f'][0])
      end

      def upload_url(filesize)
        session.request(a: 'u', s: filesize)['p']
      end
    end
  end
end
