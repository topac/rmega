module Rmega
  module Nodes
    class File < Node
      include Deletable
      include Downloadable

      def storage_url
        @storage_url ||= begin
          query_params = data["__n"] ? {n: data["__n"]} : {}
          data['g'] || request({a: 'g', g: 1, n: handle}, query_params)['g']
        end
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
