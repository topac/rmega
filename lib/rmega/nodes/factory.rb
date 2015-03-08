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

      URL_REGEXP = /mega\..+\/\#([A-Z0-9\_\-\!\=]+)/i

      FOLDER_URL_REGEXP = /mega\..+\/\#\F([A-Z0-9\_\-\!\=]+)/i

      def url?(string)
        string.to_s =~ URL_REGEXP
      end

      def build(session, data)
        type = Node::TYPES[data['t']].to_s
        return Nodes.const_get(type.capitalize).new(session, data)
      end

      def build_from_url(url, session = Session.new)
        public_handle, key = url.strip.split('!')[1, 2]

        raise "Invalid url or missing file key" unless key

        node = if url =~ FOLDER_URL_REGEXP
          nodes_data = session.request({a: 'f', c: 1, r: 1}, {n: public_handle})
          session.master_key = Utils.base64urldecode(key)
          session.storage.nodes = nodes_data['f'].map { |data| Nodes::Factory.build(session, data) }
          session.storage.nodes[0]
        else
          data = session.request(a: 'g', g: 1, p: public_handle)
          Nodes::File.new(session, data)
        end

        node.instance_variable_set('@public_handle', public_handle)
        node.instance_variable_set('@public_url', url)

        return node
      end
    end
  end
end
