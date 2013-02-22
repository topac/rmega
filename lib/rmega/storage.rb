module Rmega
  class Storage

    attr_reader :session

    def initialize session
      @session = session
    end


    # Nodes finders

    def nodes
      nodes = session.request a: 'f', c: 1
      nodes['f'].map { |node_data| Node.new(session, node_data) }
    end

    def nodes_by_type type
      nodes.select { |n| n.type == type }
    end

    def nodes_by_name name_regexp
      nodes.select do |node|
        node.name and node.name =~ name_regexp
      end
    end

    def trash_node
      @trash ||= nodes_by_type(:trash).first
    end


    # Handle node download

    def download public_url, path
      Node.initialize_by_public_url(session, public_url).download path
    end
  end
end
