module Rmega
  module Nodes
    module Traversable
      def children
        storage.nodes.select { |node| node.parent_handle == handle }
      end

      def folders
        children.select { |node| node.type == :folder }
      end

      def files
        children.select { |node| node.type == :file }
      end

      def parent
        return unless parent_handle
        storage.nodes.find { |node| node.handle == parent_handle }
      end

      def empty?
        children.size == 0
      end
    end
  end
end
