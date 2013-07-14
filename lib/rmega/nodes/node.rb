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

      delegate :storage, :request, :to => :session

      def initialize(session, data)
        @session = session
        @data = data
      end

      def public_url
        @public_url ||= begin
          b64_dec_key = Utils.a32_to_base64 decrypted_file_key[0..7]
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

      def owner_key
        data['k'].split(':').first
      end

      def name
        return attributes['n'] if attributes
      end

      def file_key
        data['k'].split(':').last
      end

      def decrypted_file_key
        if data['k']
          Crypto.decrypt_key session.master_key, Utils.base64_to_a32(file_key)
        else
          Utils.base64_to_a32 public_url.split('!').last
        end
      end

      def can_decrypt_attributes?
        !data['u'] or data['u'] == owner_key
      end

      def attributes
        @attributes ||= begin
          return nil unless can_decrypt_attributes?
          Crypto.decrypt_attributes decrypted_file_key, (data['a'] || data['at'])
        end
      end

      def type
        Factory.type(data['t'])
      end
    end
  end
end
