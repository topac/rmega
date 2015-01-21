require 'rmega/utils'
require 'rmega/crypto/aes'
require 'rmega/crypto/aes_ctr'
require 'rmega/crypto/rsa'

module Rmega
  module Crypto
    extend self

    def random_key
      Array.new(6).map { rand(0..0xFFFFFFFF) }
    end

    def prepare_key(ary)
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

    def decompose_rsa_privk(privk)
      4.times.inject([]) do |decomposed_key|
        len = ((privk[0].ord * 256 + privk[1].ord + 7) >> 3) + 2
        privk_part = privk[0, len]

        # decomposed_key << privk_part[2, privk_part.length].unpack('H*').first.to_i(16)
        decomposed_key << Utils.string_to_bignum(privk[0..len-1][2..-1])

        # a32
        # decomposed_key << Utils.mpi2b(privk[0..len-1])

        privk = privk[len..-1]

        decomposed_key
      end
    end

    def rsa_decrypt_privk(key, privk, csid)
      a32privk = decrypt_key(key, Utils.base64_to_a32(privk))
      privk = Utils.a32_to_str(a32privk)
      privk2 = privk.dup

      # Decompose private key
      rsa_privk = decompose_rsa_privk(privk)

      # Decrypt csid
      csid = Utils.base64_mpi_to_bn(csid)
      csid = Rsa.decrypt(csid, rsa_privk)

      csid = csid.to_s(16)
      csid = '0' + csid if csid.length % 2 > 0
      csid = Utils.hexstr_to_bstr(csid)[0,43]
      csid = Utils.base64urlencode(csid)

      return [rsa_privk, csid]
    end

    def encrypt_attributes(key, attributes_hash)
      a32key = key.dup
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes_str = "MEGA#{attributes_hash.to_json}"
      attributes_str << ("\x00" * (16 - (attributes_str.size % 16)))
      Crypto::Aes.encrypt a32key, Utils.str_to_a32(attributes_str)
    end

    def decrypt_attributes(key, attributes_base64)
      a32key = key.dup
      if a32key.size > 4
        a32key = [a32key[0] ^ a32key[4], a32key[1] ^ a32key[5], a32key[2] ^ a32key[6], a32key[3] ^ a32key[7]]
      end
      attributes = Crypto::Aes.decrypt a32key, Utils.base64_to_a32(attributes_base64)
      attributes = Utils.a32_to_str attributes
      JSON.parse attributes.gsub(/^MEGA/, '').rstrip
    end

    def prepare_key_pw(password_str)
      prepare_key Utils.str_to_a32(password_str)
    end

    def stringhash(aes_key, string)
      s32 = Utils::str_to_a32 string
      h32 = [0,0,0,0]

      s32.size.times { |i| h32[i & 3] ^= s32[i] }
      16384.times { h32 = Aes.encrypt aes_key, h32 }

      Utils::a32_to_base64 [h32[0],h32[2]]
    end

    def encrypt_key(key, data)
      return Aes.encrypt(key, data) if data.size == 4
      x = []
      (0..data.size).step(4) do |i|
        # cdata = [data[i] || 0, data[i+1] || 0, data[i+2] || 0, data[i+3] || 0]
        cdata = [data[i] || 0, data[i+1] || 0, data[i+2], data[i+3]].compact
        x.concat Crypto::Aes.encrypt(key, cdata)
      end
      x
    end

    def decrypt_key(key, data)
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
