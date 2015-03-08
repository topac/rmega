module Rmega
  module Nodes
    class Folder < Node
      include Expandable
      include Traversable
      include Deletable

      def download(path)
        path = ::File.join(path, self.name)
        FileUtils.mkdir_p(path)

        children.each do |node|
          node.download(path)
        end

        nil
      end
    end
  end
end
