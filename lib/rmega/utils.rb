module Rmega
  module Utils
    extend self

    def padstr str
      str.ljust(str.bytesize + ((str.bytesize) % 4), "\x00")
    end

    def str_to_a32 string
      b.pack 'N*'
    end

    def a32_to_str a32
      a32.unpack 'N*'
    end

    def base64urldecode s
      s = s+'='*((s.bytesize*3)&3)
      s = s.gsub(/\-/,'+').gsub(/_/,'/').gsub(/,/,'')
      Base64.decode64 s
    end

    def base64_to_a32 base64
      str_to_a32 base64urldecode(base64)
    end

    def b2s barr
      #28 bit integers, possibly not needed
      [barr.reverse.inject('') {|a, b| a + b.to_s(16)}].pack('H*')
    end
  end
end
