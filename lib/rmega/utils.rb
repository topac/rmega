module Rmega
  module Utils
    extend self

    def packing
      'l>*'
    end

    def str_to_a32 string
      pad_to = string.bytesize + ((string.bytesize) % 4)
      string = string.ljust pad_to, "\x00"
      string.unpack packing
    end

    def a32_to_str a32
      a32.pack packing
    end

    def b64a
      @b64a ||= ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + ["-", "_", "="]
    end

    def a32_to_base64 a32
      base64urlencode a32_to_str(a32)
    end

    def base64_to_a32 base64
      str_to_a32 base64urldecode(base64)
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

    def base64urldecode data
      data += '=='[((2-data.length*3)&3)..-1]

      i = 0
      ac = 0
      dec = ""
      tmp_arr = []

      return data unless data

      while i < data.size
        h1 = b64a.index(data[i]) || -1
        i += 1
        h2 = b64a.index(data[i]) || -1
        i += 1
        h3 = b64a.index(data[i]) || -1
        i += 1
        h4 = b64a.index(data[i]) || -1
        i += 1

        bits = (h1 << 18) | (h2 << 12) | (h3 << 6) | h4

        o1 = bits >> 16 & 0xff
        o2 = bits >> 8 & 0xff
        o3 = bits & 0xff

        if h3 == 64
          tmp_arr[ac] = o1.chr
        elsif h4 == 64
          tmp_arr[ac] = o1.chr + o2.chr
        else
          tmp_arr[ac] = o1.chr + o2.chr + o3.chr
        end

        ac += 1
      end

      tmp_arr.join ''
    end
  end
end
