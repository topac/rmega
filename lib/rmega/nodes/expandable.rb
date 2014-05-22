require 'rmega/utils'
require 'rmega/nodes/uploadable'
require 'rmega/crypto/crypto'

module Rmega
  module Nodes
    module Expandable
      include Uploadable

      def create_folder(name)
        key = Crypto.random_key
        encrypted_attributes = Utils.a32_to_base64 Crypto.encrypt_attributes(key[0..3], {n: name.strip})
        encrypted_key = Utils.a32_to_base64 Crypto.encrypt_key(session.master_key, key)
        n = [{h: 'xxxxxxxx', t: 1, a: encrypted_attributes, k: encrypted_key}]
        data = session.request a: 'p', t: handle, n: n
        Folder.new(session, data['f'][0])
      end

      def upload_url(filesize)
        session.request(a: 'u', s: filesize)['p']
      end
    end
  end
end
