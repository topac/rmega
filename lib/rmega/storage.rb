module Rmega
  class Storage
    include NotInspectable
    include Loggable
    include Crypto

    attr_reader :session

    delegate :master_key, :shared_keys, to: :session

    def initialize(session)
      @session = session
    end

    def used_space
      quota['cstrg']
    end

    def total_space
      quota['mstrg']
    end

    def quota
      session.request(a: 'uq', strg: 1)
    end

    def nodes
      results = session.request(a: 'f', c: 1)

      store_shared_keys(results['ok'] || [])

      (results['f'] || []).map do |node_data|
        node = Nodes::Factory.build(session, node_data)
        node.process_shared_key if node.shared_root?
        node
      end
    end

    def folders
      list = nodes
      root_handle = list.find { |node| node.type == :root }.handle
      list.select do |node|
        node.shared_root? || (node.type == :folder && node.parent_handle == root_handle)
      end
    end

    def trash
      @trash ||= nodes.find { |n| n.type == :trash }
    end

    def root
      @root ||= nodes.find { |n| n.type == :root }
    end

    private

    def store_shared_keys(list)
      list.each do |hash|
        shared_keys[hash['h']] = aes_ecb_decrypt(master_key, Utils.base64urldecode(hash['k']))
      end
    end
  end
end
