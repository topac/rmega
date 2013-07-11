module Rmega
  module Node
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
        storage.nodes.find { |node| node.handle == parent_handle }
      end
    end
  end
end