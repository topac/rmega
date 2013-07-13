require 'rmega/crypto/crypto'
require 'rmega/utils'
require 'rmega/nodes/node'
require 'rmega/nodes/expandable'
require 'rmega/nodes/traversable'
require 'rmega/nodes/deletable'

module Rmega
  module Nodes
    class Folder < Node
      include Expandable
      include Traversable
      include Deletable

      def download(path)
        children.each do |node|
          if node.type == :file
            node.download path
          elsif node.type == :folder
            subfolder = ::File.expand_path ::File.join(path, node.name)
            Dir.mkdir(subfolder) unless Dir.exists?(subfolder)
            node.download subfolder
          end
        end

        nil
      end
    end
  end
end
