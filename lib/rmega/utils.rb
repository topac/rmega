module Rmega
  module Utils
    extend self

    def packing
      'l>*'
    end

    def str_to_a32 string
      string.unpack packing
    end
  end
end
