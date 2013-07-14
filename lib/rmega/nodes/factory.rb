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
        type_name = type(data['t'])
        node_class = Nodes.const_get("#{type_name.to_s.capitalize}")
        node_class.new(session, data)
      end

      # TODO: support other node types than File
      def build_from_url(session, url)
        public_handle, key = url.strip.split('!')[1, 2]
        data = session.request(a: 'g', g: 1, p: public_handle)

        Nodes::File.new(session, data).tap { |n| n.public_url = url }
      end

      def mega_url?(url)
        !!(url.to_s =~ /^https:\/\/mega\.co\.nz\/#!.*$/i)
      end

      def type(number)
        founded_type = types.find { |k, v| number == v }
        founded_type.first if founded_type
      end

      def types
        {file: 0, folder: 1, root: 2, inbox: 3, trash: 4}
      end
    end
  end
end
