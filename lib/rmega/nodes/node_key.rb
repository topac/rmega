module Rmega
  module Nodes

    # The key associated to a node. It can be 128 or 256 bits long,
    # when is 256 bits long is composed by:
    # * A 128 bit AES-128 key
    # * The upper 64 bit of the counter start value (the lower 64 bit
    #   are starting at 0 and incrementing by 1 for each AES block of 16
    #   bytes)
    # * A 64 bit meta-MAC of all chunk MACs
    class NodeKey
      attr_reader :aes_key, :ctr_nonce, :meta_mac
      attr_accessor :meta_mac

      def initialize(string)
        @aes_key   = string[0..15]
        @ctr_nonce = string[16..23]
        @meta_mac  = string[24..31]
      end

      def generate
        self.class.compact("#{@aes_key}#{@ctr_nonce}#{@meta_mac}") + @ctr_nonce + @meta_mac
      end

      # note: folder key is 16 bytes long while file key is 32
      def self.load(string)
        new("#{compact(string)}#{string[16..-1]}")
      end

      def self.compact(string)
        if string.size > 16
          bytes = string.bytes
          return 16.times.inject([]) { |ary, i| ary[i] = bytes[i] ^ bytes[i+16]; ary }.map(&:chr).join
        else
          return string
        end
      end

      def self.random
        new(OpenSSL::Random.random_bytes(16 + 8 + 0))
      end
    end
  end
end
