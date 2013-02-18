module Rmega
  module Crypto
    class AesCtrCipher

      def initialize key, iv
        @cipher = OpenSSL::Cipher::AES.new 128, :CBC
        @cipher.key = key.pack packing
        @cipher.iv = iv.pack packing
      end

      def packing
        'l>*'
      end

      def decrypt data
        @cipher.decrypt
        result = @cipher.update data.pack(packing)
        result.unpack packing
      end

      # todo
      # def decrypt_to_file data, file
      #   @cipher.decrypt
      #   result = @cipher.update data.pack(packing)
      #   result.unpack packing
      # end
    end
  end
end
