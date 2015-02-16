module Rmega
  module Crypto
    module AesCtr
      def aes_ctr_cipher
        OpenSSL::Cipher::AES.new(128, :CTR)
      end

      def aes_ctr_decrypt(key, data, iv)
        cipher = aes_ctr_cipher
        cipher.decrypt
        cipher.iv = iv
        cipher.key = key
        return cipher.update(data) + cipher.final
      end

      def aes_ctr_encrypt(key, data, iv)
        cipher = aes_ctr_cipher
        cipher.encrypt
        cipher.iv = iv
        cipher.key = key
        return cipher.update(data) + cipher.final
      end
    end
  end
end
