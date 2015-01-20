module Rmega
  module Crypto
    module Rsa
      extend self

      def powm(b, p, m)
        if p == 1
          b % m
        elsif (p & 0x1) == 0
          t = powm(b, p >> 1, m)
          (t * t) % m
        else
          (b * powm(b, p-1, m)) % m
        end
      end

      def decrypt(m, pqdu)
        p, q, d, u = pqdu
        if p && q && u
          m1 = powm(m, d % (p - 1), p)
          m2 = powm(m, d % (q - 1), q)
          h = m2 - m1
          h = h + q if h < 0
          h = h * u % q
          h * p + m1
        else
          pow_m(m, d, p * q)
        end
      end
    end
  end
end
