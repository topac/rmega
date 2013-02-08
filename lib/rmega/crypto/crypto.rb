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
  end
end
