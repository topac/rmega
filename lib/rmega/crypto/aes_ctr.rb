require 'rmega/utils'
require 'rmega/crypto/aes'

module Rmega
  module Crypto
    module AesCtr
      extend self

      def decrypt(key, nonce, data)
        raise "invalid nonce" if nonce.size != 4 or !nonce.respond_to?(:pack)
        raise "invalid key" if key.size != 4 or !key.respond_to?(:pack)

        nonce = nonce.dup

        mac = [nonce[0], nonce[1], nonce[0], nonce[1]]
        enc = nil
        a32 = Utils.str_to_a32 data
        len = a32.size - 3
        last_i = 0

        (0..len).step(4) do |i|
          enc = Aes.encrypt key, nonce
          4.times do |m|
            a32[i+m] = (a32[i+m] || 0) ^ (enc[m] || 0)
            mac[m] = (mac[m] || 0) ^ (a32[i+m] || 0)
          end
          mac = Aes.encrypt key, mac
          nonce[3] += 1
          nonce[2] += 1 if nonce[3] == 0
          last_i = i + 4
        end

        if last_i < a32.size
          v = [0, 0, 0, 0]
          (last_i..a32.size - 1).step(1) { |m| v[m-last_i] = a32[m] || 0 }

          enc = Aes.encrypt key, nonce
          4.times { |m| v[m] = v[m] ^ enc[m] }

          j = data.size & 15
          m = Utils.str_to_a32 Array.new(j+1).join(255.chr)+Array.new(17-j).join(0.chr)

          4.times { |x| mac[x] = mac[x] ^ (v[x] & m[x]) }

          mac = Aes.encrypt key, mac

          (last_i..a32.size - 1).step(1) { |j| a32[j] = v[j - last_i] || 0 }
        end

        decrypted_data = Utils.a32_to_str(a32, data.size)

        {data: decrypted_data, mac: mac}
      end

      def encrypt(key, nonce, data)
        raise "invalid nonce" if nonce.size != 4 or !nonce.respond_to?(:pack)
        raise "invalid key" if key.size != 4 or !key.respond_to?(:pack)

        ctr = nonce.dup
        mac = [ctr[0], ctr[1], ctr[0], ctr[1]]
        ab32 = Utils.str_to_a32 data
        len = ab32.size - 3
        enc = nil
        last_i = 0

        (0..len).step(4) do |i|
          4.times { |x| mac[x] = mac[x] ^ (ab32[i+x] || 0) }
          mac = Aes.encrypt key, mac
          enc = Aes.encrypt key, ctr
          4.times { |x|  ab32[i+x] = (ab32[i+x] || 0) ^ (enc[x] || 0) }
          ctr[3] += 1
          ctr[2] += 1 if ctr[3].zero?
          last_i = i + 4
        end

        i = last_i

        if i < ab32.size
          v = [0, 0, 0, 0]
          (i..ab32.size - 1).step(1) { |j| v[j - i] = ab32[j] || 0 }
          4.times { |x| mac[x] = mac[x] ^ v[x] }
          mac = Aes.encrypt key, mac
          enc = Aes.encrypt key, ctr
          4.times { |x| v[x] = v[x] ^ enc[x] }
          (i..ab32.size - 1).step(1) { |j| ab32[j] = v[j - i] || 0 }
        end

        decrypted_data = Utils.a32_to_str ab32, data.size
        {data: decrypted_data, mac: mac}
      end

    end
  end
end
