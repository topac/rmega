module Rmega
  class FolderNode < Node
    def children
      storage.nodes.select { |node| node.parent_handle == handle }
    end

    # TODO - download each child
    # def download
    #   children.each { |node| node.download }
    # end
  end
end
