module Rmega
  class Session
    attr_accessor :email, :request_id, :sid, :master_key

    def initialize email, password_str
      self.email = email
      self.request_id = random_request_id

      login password_str
    end

    def debug message
      Rmega.logger.debug message
    end


    # Delegate to Rmega.options

    def options
      Rmega.options
    end

    def api_request_timeout
      options.api_request_timeout
    end

    def api_url
      options.api_url
    end


    # Cache the Storage class

    def storage
      @storage ||= Storage.new self
    end


    # Login-related methods

    def login password_str
      uh = Crypto.stringhash Crypto.prepare_key_pw(password_str), email
      resp = request a: 'us', user: email, uh: uh

      # Decrypt the master key
      encrypted_key = Crypto.prepare_key_pw password_str
      self.master_key = Crypto.decrypt_key encrypted_key, Utils.base64_to_a32(resp['k'])

      # Generate the session id
      self.sid = Crypto.decrypt_sid master_key, resp['csid'], resp['privk']
    end


    # Api requests methods

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def error_response? response
      response = response.first if response.respond_to? :first
      !!Integer(response) rescue false
    end

    def request body
      self.request_id += 1
      url = "#{api_url}?id=#{request_id}"
      url << "&sid=#{sid}" if sid
      debug "POST #{url}"
      debug "#{body.inspect}"
      response = HTTPClient.new.post url, [body].to_json, timeout: api_request_timeout
      debug "#{response.code}\n#{response.body}"
      resp = JSON.parse(response.body).first
      raise "Error code received: #{resp}" if error_response?(resp)
      resp
    end
  end
end
