module Rmega
  module Crypto
    module AesCbc
      def aes_cbc_cipher
        OpenSSL::Cipher::AES.new(128, :CBC)
      end

      def aes_cbc_encrypt(key, data)
        cipher = aes_cbc_cipher
        cipher.encrypt
        cipher.padding = 0
        cipher.key = key
        return cipher.update(data) + cipher.final
      end

      def aes_cbc_decrypt(key, data)
        cipher = aes_cbc_cipher
        cipher.decrypt
        cipher.padding = 0
        cipher.key = key
        return cipher.update(data) + cipher.final
      end

      def aes_cbc_mac(key, data, iv)
        cipher = aes_cbc_cipher
        cipher.encrypt
        cipher.padding = 0
        cipher.iv = iv if iv
        cipher.key = key

        # n = 0
        # mac = nil

        # loop do
        #   block = data[n..n+15]
        #   break if !block or block.empty?
        #   block << "\x0"*(16-block.size) if block.size < 16
        #   n += 16
        #   mac = cipher.update(block)
        # end

        # return mac

        block = data + "\x0" * ((16 - data.bytesize % 16) % 16)
        return cipher.update(block)[-16..-1]
      end
    end
  end
end
