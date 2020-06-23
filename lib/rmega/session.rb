module Rmega
  class Session
    include NotInspectable
    include Loggable
    include Net
    include Options
    include Crypto
    extend Crypto

    attr_reader :request_id, :sid, :shared_keys, :rsa_privk
    attr_accessor :master_key

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
      self.class.hash_password(password)
    end

    def self.hash_password(password)
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
      s_bytes = email.bytes.to_a
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
      # discover the version of the account (1: old accounts, >=2: newer accouts)
      resp = request(a: 'us0', user: email.strip)
      account_version = resp["v"].to_i

      # Derive an hash from the user password
      if account_version == 1
        password_hash = hash_password(password)
        u_hash = user_hash(password_hash, email.strip.downcase)
      else
        df2 = PBKDF2.new(
          :password      => password,
          :salt          => Utils.base64urldecode(resp['s']),
          :iterations    => 100000,
          :hash_function => :sha512,
          :key_length    => 16 * 2,
        ).bin_string
        password_hash = df2[0,16]
        u_hash = Utils.base64urlencode(df2[16,32])
      end

      # Send the login request
      req = {a: 'us', user: email.strip, uh: u_hash}
      req[:sek] = Utils.base64urlencode(SecureRandom.random_bytes(16)) if account_version != 1
      resp = request(req)

      @master_key = aes_cbc_decrypt(password_hash, Utils.base64urldecode(resp['k']))
      @rsa_privk = decrypt_rsa_private_key(resp['privk'])
      @sid = decrypt_session_id(resp['csid'])
      @shared_keys = {}

      return self
    end

    def ephemeral_login(user_handle, password)
      resp = request(a: 'us', user: user_handle)

      password_hash = hash_password(password)

      @master_key = aes_cbc_decrypt(password_hash, Utils.base64urldecode(resp['k']))
      @sid = resp['tsid']
      @rsa_privk = nil
      @shared_keys = {}

      return self
    end

    def self.ephemeral
      master_key = OpenSSL::Random.random_bytes(16)
      password = OpenSSL::Random.random_bytes(16)
      password_hash = hash_password(password)
      challenge = OpenSSL::Random.random_bytes(16)

      session = new

      user_handle = session.request(a: 'up', k: Utils.base64urlencode(aes_ecb_encrypt(password_hash, master_key)),
        ts: Utils.base64urlencode(challenge + aes_ecb_encrypt(master_key, challenge)))

      return session.ephemeral_login(user_handle, password)
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def request_url(params = {})
      params = params.merge(sid: @sid) if @sid
      params = params.to_a.map { |a| a.join("=") }.join("&")
      params = "&#{params}" unless params.empty?

      return "#{options.api_url}?id=#{@request_id}#{params}"
    end

    def request(body, query_params = {})
      survive do
        @request_id += 1
        api_response = APIResponse.new(http_post(request_url(query_params), [body].to_json))
        if api_response.ok?
          return(api_response.as_json)
        else
          raise(api_response.as_error)
        end
      end
    end
  end
end
