require 'rmega/crypto/aes_ecb'
require 'rmega/crypto/aes_cbc'
require 'rmega/crypto/aes_ctr'
require 'rmega/crypto/rsa'

module Rmega
  module Crypto
    include AesCbc
    include AesEcb
    include AesCtr
    include Rsa

    # Check if all the used ciphers are supported
    ciphers = OpenSSL::Cipher.ciphers.map(&:upcase)
    %w[AES-128-CBC AES-128-CTR AES-128-ECB].each do |name|
      next if ciphers.include?(name)
      warn "WARNING: Your Ruby is compiled with OpenSSL #{OpenSSL::VERSION} and does not support cipher #{name}."
    end
  end
end
