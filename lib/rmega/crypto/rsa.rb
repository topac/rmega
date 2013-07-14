require 'execjs'

module Rmega
  module Crypto
    module Rsa
      extend self

      def script_path
        File.join File.dirname(__FILE__), 'rsa_mega.js'
      end

      def context
        @context ||= ExecJS.compile File.read(script_path)
      end

      def decrypt(t, privk)
        context.call "RSAdecrypt", t, privk[2], privk[0], privk[1], privk[3]
      end
    end
  end
end
