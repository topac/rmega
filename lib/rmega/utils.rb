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

    def b64a
      @b64a ||= ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + ["-", "_", "="]
    end

    def base64urlencode string
      i = 0
      tmp_arr = []

      while i < string.size + 1
        o1 = string[i].ord rescue 0
        i += 1
        o2 = string[i].ord rescue 0
        i += 1
        o3 = string[i].ord rescue 0
        i += 1

        bits = o1 << 16 | o2 << 8 | o3

        h1 = bits >> 18 & 0x3f
        h2 = bits >> 12 & 0x3f
        h3 = bits >> 6 & 0x3f
        h4 = bits & 0x3f

        tmp_arr.push b64a[h1] + b64a[h2] + b64a[h3] + b64a[h4]
      end

      enc = tmp_arr.join ''
      r = string.size % 3
      (r != 0) ? enc[0..r - 4] : enc
    end
  end
end
