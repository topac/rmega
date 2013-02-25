module Rmega
  module Crypto
    extend self

    def prepare_key ary
      pkey = [0x93C467E3,0x7DB0C7A4,0xD1BE3F81,0x0152CB56]
      65536.times do
        0.step(ary.size-1, 4) do |j|
          key = [0,0,0,0]
          4.times do |i|
            key[i] = ary[i+j] if i+j < ary.size
          end
          pkey = Aes.encrypt key, pkey
        end
      end
      pkey
    end

    def decrypt_sid key, csid, privk
      # if csid ...
      t = Utils.mpi2b Utils.base64urldecode(csid)
      privk = Utils.a32_to_str decrypt_key(key, Utils.base64_to_a32(privk))
      rsa_privk = Array.new 4
      # else if tsid (todo)

      # Decompose private key
      4.times do |i|
        l = ((privk[0].ord * 256 + privk[1].ord + 7) >> 3) + 2
        rsa_privk[i] = Utils.mpi2b privk[0..l-1]
        privk = privk[l..-1]
      end

      # TODO - remove execjs and build the key using the ruby lib
      # rsa_key = Crypto::Rsa.build_rsa_key rsa_privk
      decrypted_t = Rsa.decrypt t, rsa_privk
      Utils.base64urlencode Utils.b2s(decrypted_t)[0..42]
    end

    def encrypt_attributes key, attributes_hash
      a32key = key.dup
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes_str = "MEGA#{attributes_hash.to_json}"
      attributes_str << ("\x00" * (16 - (attributes_str.size % 16)))
      Crypto::Aes.encrypt a32key, Utils.str_to_a32(attributes_str)
    end

    def decrypt_attributes key, attributes_base64
      a32key = key.dup
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes = Crypto::Aes.decrypt a32key, Utils.base64_to_a32(attributes_base64)
      attributes = Utils.a32_to_str attributes
      JSON.parse attributes.gsub(/^MEGA/, '').rstrip
    end

    def prepare_key_pw password_str
      prepare_key Utils.str_to_a32(password_str)
    end

    def stringhash aes_key, string
      s32 = Utils::str_to_a32 string
      h32 = [0,0,0,0]

      s32.size.times { |i| h32[i & 3] ^= s32[i] }
      16384.times { h32 = Aes.encrypt aes_key, h32 }

      Utils::a32_to_base64 [h32[0],h32[2]]
    end

    def encrypt_key key, data
      return Aes.encrypt(key, data) if data.size == 4
      x = []
      (0..data.size).step(4) do |i|
        # cdata = [data[i] || 0, data[i+1] || 0, data[i+2] || 0, data[i+3] || 0]
        cdata = [data[i] || 0, data[i+1] || 0, data[i+2], data[i+3]].compact
        x.concat Crypto::Aes.encrypt(key, cdata)
      end
      x
    end

    def decrypt_key key, data
      return Aes.decrypt(key, data) if data.size == 4
      x = []
      (0..data.size).step(4) do |i|
        cdata = [data[i] || 0, data[i+1] || 0, data[i+2] || 0, data[i+3] || 0]
        x.concat Crypto::Aes.decrypt(key, cdata)
      end
      x
    end
  end
end
