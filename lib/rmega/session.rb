module Rmega
  class Session
    include NotInspectable
    include Loggable
    include Crypto
    include Net
    include Options

    attr_reader :request_id, :sid, :master_key, :shared_keys, :rsa_privk

    def initialize
      @request_id = random_request_id
      @shared_keys = {}
    end

    def storage
      @storage ||= Storage.new(self)
    end

    def decrypt_rsa_private_key(encrypted_privk)
      privk = aes_ecb_decrypt(@master_key, Utils.base64urldecode(encrypted_privk))

      # Decompose private key
      decomposed_key = []

      4.times do
        len = ((privk[0].ord * 256 + privk[1].ord + 7) >> 3) + 2
        privk_part = privk[0, len]
        decomposed_key << Utils.string_to_bignum(privk[0..len-1][2..-1])
        privk = privk[len..-1]
      end

      return decomposed_key
    end

    def hash_password(password)
      pwd = password.dup.force_encoding('BINARY')
      pkey = "\x93\xc4\x67\xe3\x7d\xb0\xc7\xa4\xd1\xbe\x3f\x81\x1\x52\xcb\x56".force_encoding('BINARY')
      null_byte = "\x0".force_encoding('BINARY').freeze
      blank = (null_byte*16).force_encoding('BINARY').freeze
      keys = {}

      65536.times do
        (0..pwd.size-1).step(16) do |j|

          keys[j] ||= begin
            key = blank.dup
            16.times { |i| key[i] = pwd[i+j] || null_byte if i+j < pwd.size }
            key
          end

          pkey = aes_ecb_encrypt(keys[j], pkey)
        end
      end

      return pkey
    end

    def decrypt_session_id(csid)
      csid = Utils.base64_mpi_to_bn(csid)
      csid = rsa_decrypt(csid, @rsa_privk)
      csid = csid.to_s(16)
      csid = '0' + csid if csid.length % 2 > 0
      csid = Utils.hexstr_to_bstr(csid)[0,43]
      csid = Utils.base64urlencode(csid)
      return csid
    end

    def user_hash(aes_key, email)
      s_bytes = email.bytes
      hash = Array.new(16, 0)
      s_bytes.size.times { |n| hash[n & 15] = hash[n & 15] ^ s_bytes[n] }
      hash = hash.pack('c*')
      16384.times { hash = aes_ecb_encrypt(aes_key, hash) }
      hash = hash[0..4-1] + hash[8..12-1]
      return Utils.base64urlencode(hash)
    end

    # If the user_hash is found on the server it returns:
    # * The user master_key (128 bit for AES) encrypted with the password_hash
    # * The RSA private key ecrypted with the master_key
    # * A brand new session_id encrypted with the RSA private key
    def login(email, password)
      # Derive an hash from the user password
      password_hash = hash_password(password)
      u_hash = user_hash(password_hash, email.strip.downcase)

      resp = request(a: 'us', user: email.strip, uh: u_hash)

      @master_key = aes_cbc_decrypt(password_hash, Utils.base64urldecode(resp['k']))
      @rsa_privk = decrypt_rsa_private_key(resp['privk'])
      @sid = decrypt_session_id(resp['csid'])

      return self
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def request_url
      "#{options.api_url}?id=#{@request_id}" + (@sid ? "&sid=#{@sid}" : "")
    end

    def request(content)
      survive do
        @request_id += 1
        api_response = APIResponse.new(http_post(request_url, [content].to_json))
        if api_response.ok?
          return(api_response.as_json)
        else
          raise(api_response.as_error)
        end
      end
    end
  end
end
