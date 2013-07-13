require 'rmega/utils'
require 'rmega/crypto/crypto'

module Rmega
  module Nodes
    module Deletable
      def delete
        request(a: 'd', n: handle)
      end

      def trash
        request(a: 'm', n: handle, t: storage.trash_node.public_handle)
      end
    end
  end
end
