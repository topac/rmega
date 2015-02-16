require 'rmega/nodes/uploadable'
require 'rmega/nodes/expandable'
require 'rmega/nodes/downloadable'
require 'rmega/nodes/deletable'
require 'rmega/nodes/traversable'
require 'rmega/nodes/node_key'
require 'rmega/nodes/node'
require 'rmega/nodes/file'
require 'rmega/nodes/folder'
require 'rmega/nodes/inbox'
require 'rmega/nodes/root'
require 'rmega/nodes/trash'

module Rmega
  module Nodes
    module Factory
      extend self

      def build(session, data)
        if data.kind_of?(String)
          return build_from_url(session, data)
        else
          klass = Nodes.const_get(Node::TYPES[data['t']].to_s.capitalize)
          return klass.new(session, data)
        end
      end

      # TODO: support other node types than File
      def build_from_url(session, url)
        public_handle, key = url.strip.split('!')[1, 2]
        raise "Invalid url or missing file key" unless key
        data = session.request(a: 'g', g: 1, p: public_handle)

        node = Nodes::File.new(session, data)
        node.instance_variable_set('@public_handle', public_handle)
        node.instance_variable_set('@public_url', url)
        return node
      end
    end
  end
end
