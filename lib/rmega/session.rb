module Rmega
  class Session
    attr_accessor :email, :request_id

    def initialize email, password_str
      self.email = email
      self.request_id = random_request_id

      login password_str
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def login password_str
      uh = Crypto.stringhash Crypto.prepare_key_pw(password_str), email
      response = request '[{"a":"us","user":"'+email+'","uh":"'+uh+'"}]'
    end

    def request body
      self.request_id += 1
      HTTParty.post "#{api_url}?id=#{request_id}", :body => body
    end

    def api_url
      "https://eu.api.mega.co.nz/cs"
    end
  end
end
