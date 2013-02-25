module Rmega
  module Utils
    extend self

    def show_progress direction, total, increment = 0
      return unless Rmega.options.show_progress
      @progressbar_progress = 0 if increment.zero?
      @progressbar_progress += increment
      format = "#{direction.to_s.capitalize} in progress #{Utils.format_bytes(@progressbar_progress)} of #{Utils.format_bytes(total)} | %P% | %e        "
      @progressbar ||= ProgressBar.create format: format, total: total
      @progressbar.reset if increment.zero?
      @progressbar.format format
      @progressbar.progress += increment
    end

    def format_bytes bytes, round = 2
      units = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB']
      e = (bytes == 0 ? 0 : Math.log(bytes)) / Math.log(1024)
      value = bytes.to_f / (1024 ** e.floor)
      "#{value.round(round)}#{units[e]}"
    end

    def str_to_a32 string
      pad_to = string.bytesize + ((string.bytesize) % 4)
      string = string.ljust pad_to, "\x00"
      string.unpack 'l>*'
    end

    def a32_to_str a32, len=nil
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

    def mpi2b s
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

    def b2s b
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
  end
end
