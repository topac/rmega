module Rmega
  module Nodes
    class Root < Node
      include Expandable
      include Traversable

      def download(path)
        children.each do |node|
          node.download(path)
        end
      end
    end
  end
end
