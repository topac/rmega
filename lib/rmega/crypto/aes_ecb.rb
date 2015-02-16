module Rmega
  module Crypto
    module AesEcb
      def aes_ecb_cipher
        OpenSSL::Cipher::AES.new(128, :ECB)
      end

      def aes_ecb_encrypt(key, data)
        cipher = aes_ecb_cipher
        cipher.encrypt
        cipher.padding = 0
        cipher.key = key
        return cipher.update(data) + cipher.final
      end

      def aes_ecb_decrypt(key, data)
        cipher = aes_ecb_cipher
        cipher.decrypt
        cipher.padding = 0
        cipher.key = key
        return cipher.update(data) + cipher.final
      end
    end
  end
end
