module Rmega
  class Session
    include Commands

    attr_accessor :email, :request_id, :sid, :requests_timeout

    def initialize email, password_str
      self.email = email
      self.request_id = random_request_id
      self.requests_timeout = 20

      login password_str
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def login password_str
      uh = Crypto.stringhash Crypto.prepare_key_pw(password_str), email
      resp = request a: 'us', user: email, uh: uh
      raise "Error code received: #{resp}" if error_response?(resp)
      self.sid = Crypto.get_sid2 password_str, resp['csid'], resp['privk'], resp['k']
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
      response = HTTParty.post url, :body => [body].to_json, :timeout => requests_timeout
      Rmega.logger.debug "#{response.code}"
      Rmega.logger.debug "#{response}"
      response.first
    end

    def api_url
      "https://eu.api.mega.co.nz/cs"
    end
  end
end
