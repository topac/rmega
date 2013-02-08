module Rmega
  class Session
    attr_accessor :email, :request_id

    def initialize email
      self.email = email
      self.request_id = 1259519804
    end

    def login password_str
      uh = Crypto.stringhash Crypto.prepare_key_pw(password_str), email
      response = request '[{"a":"us","user":"'+email+'","uh":"'+uh+'"}]'
    end

    def request body
      self.request_id += 1
      puts body
      resp = HTTParty.post "#{api_url}?id=#{request_id}", :body => body
      puts resp.body
      resp
    end

    def api_url
      "https://eu.api.mega.co.nz/cs"
    end
  end
end
