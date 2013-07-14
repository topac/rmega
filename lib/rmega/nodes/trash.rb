require 'rmega/nodes/node'
require 'rmega/nodes/traversable'

module Rmega
  module Nodes
    class Trash < Node
      include Traversable

      def empty!
        children.each do |node|
          node.delete if node.respond_to?(:delete)
        end

        empty?
      end
    end
  end
end
