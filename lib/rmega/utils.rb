require 'base64'

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

    def b64a
      @b64a ||= ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a + ["-", "_", "="]
    end

    def a32_to_base64(a32)
      base64urlencode a32_to_str(a32)
    end

    def base64_to_a32(base64)
      str_to_a32 base64urldecode(base64)
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

    def mpi2b(s)
      bn = 1
      r = [0]
      rn = 0
      sb = 256
      sn = s.size
      bm = 268435455
      c = nil

      return 0 if sn < 2

      len = (sn - 2) * 8
      bits = s[0].ord * 256 + s[1].ord

      return 0 if bits > len or bits < len - 8

      len.times do |n|
        sb = sb << 1

        if sb > 255
          sb = 1
          c = s[sn -= 1].ord
        end

        if bn > bm
          bn = 1
          r[rn += 1] = 0
        end

        if (c & sb) and (c & sb != 0)
          r[rn] = r[rn] ? (r[rn] | bn) : bn
        end

        bn = bn << 1
      end
      r
    end

    def b2s(b)
      bs = 28
      bm = 268435455
      bn = 1; bc = 0; r = [0]; rb = 1; rn = 0
      bits = b.length * bs
      rr = ''

      bits.times do |n|
        if (b[bc] & bn) and (b[bc] & bn) != 0
          r[rn] = r[rn] ? (r[rn] | rb) : rb
        end

        rb = rb << 1

        if rb > 255
          rb = 1
          r[rn += 1] = 0
        end

        bn = bn << 1

        if bn > bm
          bn = 1
          bc += 1
        end
      end

      while rn >= 0 && r[rn] == 0
        rn -= 1
      end

      (rn + 1).times do |n|
        rr = r[n].chr + rr
      end

      rr
    end

    def chunks(size)
      list = {}
      p = 0
      pp = 0
      i = 1

      while i <= 8 and p < size - (i * 0x20000)
        list[p] = i * 0x20000
        pp = p
        p += list[p]
        i += 1
      end

      while p < size
        list[p] = 0x100000
        pp = p
        p += list[p]
      end

      if size - pp > 0
        list[pp] = size - pp
      end
      list
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
  end
end
