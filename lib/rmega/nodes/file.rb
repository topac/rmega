module Rmega
  module Nodes
    class File < Node
      include Deletable
      include Downloadable

      def storage_url
        @storage_url ||= data['g'] || request(a: 'g', g: 1, n: handle)['g']
      end

      def size
        data['s']
      end

      def filesize
        size
      end
    end
  end
end
