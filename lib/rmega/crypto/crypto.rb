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

    def decrypt_key key, data
      return Aes.decrypt(key, data) if data.size == 4

      x = []

      (0..data.size - 4).step(4) do |i|
        cdata = [data[i], data[i+1], data[i+2], data[i+3]]
        x.concat Aes.decrypt(key, cdata)
      end
      x
    end

    def get_sid2 password_str, csid, privk, k
      r = false

      aes_key = prepare_key_pw password_str
      k = decrypt_key aes_key, Utils.base64_to_a32(k)
      aes_key = k

      # if csid ...
      t = Utils.mpi2b Utils.base64urldecode(csid)
      privk = Utils.a32_to_str decrypt_key(aes_key, Utils.base64_to_a32(privk))
      rsa_privk = Array.new 4

      # decompose private key
      4.times do |i|
        l = ((privk[0].ord * 256 + privk[1].ord + 7) >> 3) + 2
        rsa_privk[i] = Utils.mpi2b privk[0..l-1]
        privk = privk[l..-1]
      end

      # todo - remove execjs and build the key using the ruby lib
      # rsa_key = build_rsa_key rsa_privk
      decrypted_t = Rsa.decrypt t, privk
      sid =  Utils.base64urlencode Utils.b2s(decrypted_t)[0..42]
      r = [k, sid, rsa_privk]
      sid
    end
  end
end
