module Rmega
  module Nodes
    module Expandable
      include Uploadable

      def create_folder(name)
        key = OpenSSL::Random.random_bytes(24) #128 bit key + 64 bit nonce

        # encrypt attributes
        attributes_str = "MEGA"
        attributes_str << {n: name.strip}.to_json
        attributes_str << ("\x00" * (16 - (attributes_str.size % 16)))
        encrypted_attributes = aes_cbc_encrypt(key[0..15], attributes_str)

        # Encrypt node key
        encrypted_key = aes_ecb_encrypt(session.master_key, key[0..15])

        n = [{h: 'xxxxxxxx', t: 1, a: Utils.base64urlencode(encrypted_attributes), k: Utils.base64urlencode(encrypted_key)}]
        data = session.request(a: 'p', t: handle, n: n)
        Folder.new(session, data['f'][0])
      end

      def upload_url(filesize)
        session.request(a: 'u', s: filesize)['p']
      end
    end
  end
end
