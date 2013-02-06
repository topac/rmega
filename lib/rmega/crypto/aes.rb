module Rmega
  module Crypto
    module Aes
      extend self

      def js_script_path
        File.join File.dirname(__FILE__), 'sjcl.js'
      end

      def script_content
        hook = 'var encrypt = function(key, data){aes = new sjcl.cipher.aes(key); return aes.encrypt(data);}'
        File.read(js_script_path)+hook
      end

      def context
        @context ||= ExecJS.compile script_content
      end

      def encrypt key, data
        context.call 'encrypt', key, data
      end
    end
  end
end
