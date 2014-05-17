require 'rmega/loggable'
require 'rmega/utils'
require 'rmega/crypto/crypto'
require 'rmega/nodes/traversable'

module Rmega
  module Nodes
    class Node
      include Loggable
      include Traversable

      attr_reader :data, :session

      delegate :storage, :request, :shared_keys, :rsa_privk, :to => :session

      def initialize(session, data)
        @session = session
        @data = data
      end

      def public_url
        @public_url ||= begin
          b64_dec_key = Utils.a32_to_base64(decrypted_file_key[0..7])
          "https://mega.co.nz/#!#{public_handle}!#{b64_dec_key}"
        end
      end

      def public_url=(url)
        @public_url = url
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
          hash[h] = k
          hash
        end
      end

      def file_key
        file_keys.values.first
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
          sk = Rmega::Utils.mpi2b(Rmega::Utils.base64urldecode(sk))
          dec_sk = Rmega::Crypto::Rsa.decrypt(sk, rsa_privk)
          Utils.str_to_a32(Rmega::Utils.b2s(dec_sk)[0..15])
        else
          Crypto.decrypt_key session.master_key, Utils.base64_to_a32(data['sk'])
        end

        shared_keys[handle] = shared_key
        [handle, shared_key]
      end

      def decrypted_file_key
        h, shared_key = *process_shared_key

        if shared_key
          Crypto.decrypt_key(shared_key, Utils.base64_to_a32(file_keys[h]))
        elsif file_key
          Crypto.decrypt_key(session.master_key, Utils.base64_to_a32(file_key))
        else
          Utils.base64_to_a32(public_url.split('!').last)
        end
      end

      def attributes
        encrypted = data['a'] || data['at']
        return if !encrypted or encrypted.empty?
        Crypto.decrypt_attributes(decrypted_file_key, encrypted)
      end

      def type
        Factory.type(data['t'])
      end
    end
  end
end
