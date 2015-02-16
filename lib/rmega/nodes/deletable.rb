module Rmega
  module Nodes
    module Deletable
      def delete
        request(a: 'd', n: handle)
      end

      def trash
        request(a: 'm', n: handle, t: storage.trash.handle)
      end
    end
  end
end
