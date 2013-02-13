module Rmega
  class Session
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
      resp = request '[{"a":"us","user":"'+email+'","uh":"'+uh+'"}]'
      resp = resp.first
      self.sid = Crypto.get_sid2 password_str, resp['csid'], resp['privk'], resp['k']
    end

    def request body
      self.request_id += 1
      query_string = "?id=#{request_id}"
      query_string << "sid=#{sid}" if sid
      HTTParty.post "#{api_url}#{query_string}", :body => body, :timeout => requests_timeout
    end

    def api_url
      "https://eu.api.mega.co.nz/cs"
    end
  end
end
