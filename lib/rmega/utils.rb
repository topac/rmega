module Rmega
  module Utils
    extend self

    def packing
      'l>*'
    end

    def str_to_a32 string
      string.unpack packing
    end

    def a32_to_str a32
      a32.pack packing
    end
  end
end
