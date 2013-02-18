module Rmega
  class Session
    attr_accessor :email, :request_id, :sid, :requests_timeout, :master_key

    def initialize email, password_str
      self.email = email
      self.request_id = random_request_id
      self.requests_timeout = 20

      login password_str
    end

    def decrypt_master_key password_str, k
      ancrypted_key = Crypto.prepare_key_pw password_str
      self.master_key = Crypto.decrypt_key ancrypted_key, Utils.base64_to_a32(k)
    end

    def decrypt_sid csid, privk
      # if csid ...
      t = Utils.mpi2b Utils.base64urldecode(csid)
      privk = Utils.a32_to_str Crypto.decrypt_key(self.master_key, Utils.base64_to_a32(privk))
      rsa_privk = Array.new 4
      # else if tsid (todo)

      # Decompose private key
      4.times do |i|
        l = ((privk[0].ord * 256 + privk[1].ord + 7) >> 3) + 2
        rsa_privk[i] = Utils.mpi2b privk[0..l-1]
        privk = privk[l..-1]
      end

      # TODO - remove execjs and build the key using the ruby lib
      # rsa_key = Crypto::Rsa.build_rsa_key rsa_privk
      decrypted_t = Crypto::Rsa.decrypt t, rsa_privk
      self.sid =  Utils.base64urlencode Utils.b2s(decrypted_t)[0..42]
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def login password_str
      uh = Crypto.stringhash Crypto.prepare_key_pw(password_str), email
      resp = request a: 'us', user: email, uh: uh
      raise "Error code received: #{resp}" if error_response?(resp)
      decrypt_master_key password_str, resp['k']
      decrypt_sid resp['csid'], resp['privk']
    end

    def error_response? response
      response = response.first if response.respond_to? :first
      !!Integer(response) rescue false
    end

    def request body
      self.request_id += 1
      url = "#{api_url}?id=#{request_id}"
      url << "&sid=#{sid}" if sid
      Rmega.logger.debug "POST #{url}"
      Rmega.logger.debug "#{body.inspect}"
      response = HTTPClient.new.post url, [body].to_json
      Rmega.logger.debug "#{response.code}"
      Rmega.logger.debug "#{response.body}"
      JSON.parse(response.body).first
    end

    def api_url
      "https://eu.api.mega.co.nz/cs"
    end
  end
end
