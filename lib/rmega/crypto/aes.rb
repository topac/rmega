module Rmega
  module Crypto
    module Aes
      extend self

      def packing
        'l>*'
      end

      def cipher
        @cipher ||= OpenSSL::Cipher::AES.new 128, :CBC
      end

      def encrypt key, data
        cipher.reset
        cipher.padding = 0
        cipher.encrypt
        cipher.key = key.pack packing
        result = cipher.update data.pack(packing)
        result.unpack packing
      end

      def decrypt key, data
        cipher.reset
        cipher.padding = 0
        cipher.decrypt
        cipher.key = key.pack packing
        result = cipher.update data.pack(packing)
        result.unpack packing
      end
    end
  end
end
