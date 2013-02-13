module Rmega
  module Crypto
    module Rsa
      extend self

      # def a32_to_bn a32
      #   binary_string = Utils.a32_to_str(a32).unpack('B*').first
      #   OpenSSL::BN.new binary_string, 2
      # end

      # def build_rsa_key privk
      #   n = a32_to_bn(privk[0]) * a32_to_bn(privk[1])
      #   e = 0
      #   d = a32_to_bn(privk[2])
      #   p = a32_to_bn(privk[0])
      #   q = a32_to_bn(privk[1])

      #   a = OpenSSL::PKey::RSA.new
      #   a.n = n
      #   a.e = e
      #   if p and q
      #     a.p = p
      #     a.q = q
      #     raise "n != p * q" unless a.n == a.p * a.q
      #     a.d = d || a.e.mod_inverse((a.p-1)*(a.q-1))
      #     a.dmp1 = a.d % (a.p-1)
      #     a.dmq1 = a.d % (a.q-1)
      #     a.iqmp = a.q.mod_inverse(a.p)
      #   else
      #     a.d = d
      #     a.p = nil
      #     a.q = nil
      #   end
      #   a
      # end

      def script_path
        File.join File.dirname(__FILE__), 'rsa_mega.js'
      end

      def context
        @context ||= ExecJS.compile File.read(script_path)
      end

      def decrypt t, privk
        context.call "RSAdecrypt", t, privk[2], privk[0], privk[1], privk[3]
      end
    end
  end
end
