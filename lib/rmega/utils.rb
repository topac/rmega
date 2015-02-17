module Rmega
  module Utils
    extend self

    def str_to_a32(string)
      size = (string.bytesize + 3) >> 2
      string = string.ljust (string.bytesize + 3), "\x00"
      string.unpack "l>#{size}"
    end

    def a32_to_str(a32, len = nil)
      if len
        b = []
        len.times do |i|
          # TODO: should be ((a32[i>>2] >>> (24-(i & 3)*8)) & 255)
          b << (((a32[i>>2] || 0) >> (24-(i & 3)*8)) & 255)
        end
        b.pack 'C*'
      else
        a32.pack 'l>*'
      end
    end

    def base64urlencode(string)
      r = string.size % 3
      encoded = Base64.urlsafe_encode64(string)
      return (r != 0) ? encoded[0..r - 4] : encoded
    end

    def base64urldecode(data)
      fix_for_decoding = '=='[((2-data.length*3)&3)..-1]
      return Base64.urlsafe_decode64("#{data}#{fix_for_decoding}")
    end

    def hexstr_to_bstr(h)
      bstr = ''
      (0..h.length-1).step(2) {|n| bstr << h[n,2].to_i(16).chr }
      bstr
    end

    def string_to_bignum(string)
      string.bytes.inject { |a, b| (a << 8) + b }
    end

    def base64_mpi_to_bn(s)
      data = ::Rmega::Utils.base64urldecode(s)
      len = ((data[0].ord * 256 + data[1].ord + 7) / 8) + 2
      data[2,len+2].unpack('H*').first.to_i(16)
    end

    def compact_to_8_bytes(string)
      raise("Invalid data length") if string.size != 16

      bytes = string.bytes.to_a

      return 8.times.inject([]) do |ary, i|
        n = i < 4 ? 0 : 4
        ary[i] = bytes[i+n] ^ bytes[i+n+4]
        ary
      end.map(&:chr).join
    end
  end
end
