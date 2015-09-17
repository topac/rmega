module Rmega
  class Storage
    include NotInspectable
    include Loggable
    include Crypto

    attr_reader :session

    # Delegate to :session
    [:master_key, :shared_keys].each do |name|
      __send__(:define_method, name) { |*args| session.__send__(name, *args) }
    end

    def initialize(session)
      @session = session
    end

    def used_space
      quota['cstrg']
    end

    def total_space
      quota['mstrg']
    end

    def stats
      stats_hash = {files: 0, size: 0}

      nodes.each do |n|
        next unless n.type == :file
        stats_hash[:files] += 1
        stats_hash[:size] += n.filesize
      end

      return stats_hash
    end

    def quota
      session.request(a: 'uq', strg: 1)
    end

    def nodes=(list)
      @nodes = list
    end

    def nodes
      return @nodes if @nodes

      results = session.request(a: 'f', c: 1)

      (results['ok'] || []).each do |hash|
        shared_keys[hash['h']] ||= aes_ecb_decrypt(master_key, Utils.base64urldecode(hash['k']))
      end

      (results['f'] || []).map do |node_data|
        node = Nodes::Factory.build(session, node_data)
        node.process_shared_key if node.shared_root?
        node
      end
    end

    def shared
      nodes.select { |node| node.shared_root? }
    end

    def trash
      @trash ||= nodes.find { |n| n.type == :trash }
    end

    def root
      @root ||= nodes.find { |n| n.type == :root }
    end
  end
end
