module Rmega
  module Nodes
    class Node
      include NotInspectable
      include Loggable
      include Traversable
      include Crypto

      attr_reader :data, :session

      # Delegate to :session
      [:request, :shared_keys, :rsa_privk, :master_key, :storage].each do |name|
        __send__(:define_method, name) { |*args| session.__send__(name, *args) }
      end

      TYPES = {0 => :file, 1 => :folder, 2 => :root, 3 => :inbox, 4 => :trash}

      def initialize(session, data)
        @session = session
        @data = data
      end

      def public_url
        @public_url ||= "https://mega.co.nz/#!#{public_handle}!#{Utils.base64urlencode(decrypted_file_key)}"
      end

      def public_handle
        @public_handle ||= request(a: 'l', n: handle)
      end

      def handle
        data['h']
      end

      def parent_handle
        data['p']
      end

      def name
        attributes['n'] if attributes
      end

      def file_keys
        return {} unless data['k']

        pairs = data['k'].split('/')
        pairs.inject({}) do |hash, pair|
          h, k = pair.split(':')
          hash[h] = Utils.base64urldecode(k)
          hash
        end
      end

      def file_key
        k = file_keys.values.first
        return k ? k : nil
      end

      def shared_root?
        data['su'] && data['sk'] && data['k']
      end

      def process_shared_key
        h = (shared_keys.keys & file_keys.keys).first
        return [h, shared_keys[h]] if h

        sk = data['sk']

        return unless sk

        shared_key = if sk.size > 22
          # Decrypt sk
          sk = Utils.base64_mpi_to_bn(sk)
          sk = rsa_decrypt(sk, rsa_privk)
          sk = sk.to_s(16)
          sk = '0' + sk if sk.size % 2 > 0
          Utils.hexstr_to_bstr(sk)[0..15]
        else
          aes_ecb_decrypt(master_key, Utils.base64urldecode(sk))
        end

        shared_keys[handle] = shared_key
        [handle, shared_key]
      end

      def self.each_chunk(size, &block)
        start, p = 0, 0

        return if size <= 0

        loop do
          offset = p < 8 ? (131072 * (p += 1)) : 1048576
          next_start = offset + start

          if next_start >= size
            yield(start, size - start)
            break
          else
            yield(start, offset)
            start = next_start
          end
        end
      end

      def each_chunk(&block)
        self.class.each_chunk(filesize, &block)
      end

      def decrypted_file_key
        h, shared_key = *process_shared_key

        if shared_key
          aes_ecb_decrypt(shared_key, file_keys[h])
        elsif file_key
          aes_ecb_decrypt(master_key, file_key)
        else
          Utils.base64urldecode(public_url.split('!').last)
        end
      end

      def attributes
        encrypted = data['a'] || data['at']
        return if !encrypted or encrypted.empty?
        node_key = NodeKey.load(decrypted_file_key)
        encrypted = Utils.base64urldecode(encrypted)
        encrypted.strip! if encrypted.size % 16 != 0 # Fix possible errors
        json = aes_cbc_decrypt(node_key.aes_key, encrypted)
        # Remove invalid bytes at the end of the string
        json.strip!
        json.gsub!(/^MEGA\{(.+)\}.*/, '{\1}')
        return JSON.parse(json)
      end

      def type
        TYPES[data['t']]
      end
    end
  end
end
