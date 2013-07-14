require 'rmega/utils'
require 'rmega/crypto/crypto'
require 'rmega/nodes/factory'

module Rmega
  class Storage
    include Loggable

    attr_reader :session

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
      session.request a: 'uq', strg: 1
    end

    def nodes
      result = session.request(a: 'f', c: 1)
      result['f'].map { |node_data| Nodes::Factory.build(session, node_data) }
    end

    def trash
      @trash ||= nodes.find { |n| n.type == :trash }
    end

    def root
      @root_node ||= nodes.find { |n| n.type == :root }
    end

    def download(public_url, path)
      Nodes::Factory.build_from_url(session, public_url).download(path)
    end
  end
end
