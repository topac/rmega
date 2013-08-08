require 'rmega/storage'
require 'rmega/request_error'
require 'rmega/crypto/crypto'
require 'rmega/utils'

module Rmega
  def self.login(email, password)
    Session.new(email, password).storage
  end

  class Session
    include Loggable

    attr_reader :email, :request_id, :sid, :master_key

    def initialize(email, password)
      @email = email
      @request_id = random_request_id

      login(password)
    end

    def options
      Rmega.options
    end

    delegate :api_url, :api_request_timeout, to: :options

    def storage
      @storage ||= Storage.new(self)
    end

    def login(password)
      uh = Crypto.stringhash Crypto.prepare_key_pw(password), email.downcase
      resp = request(a: 'us', user: email, uh: uh)

      # Decrypts the master key
      encrypted_key = Crypto.prepare_key_pw(password)
      @master_key = Crypto.decrypt_key(encrypted_key, Utils.base64_to_a32(resp['k']))

      # Generates the session id
      @sid = Crypto.decrypt_sid(@master_key, resp['csid'], resp['privk'])
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def request_url
      "#{api_url}?id=#{@request_id}".tap do |url|
        url << "&sid=#{@sid}" if @sid
      end
    end

    def request(body)
      @request_id += 1
      logger.debug "POST #{request_url}\n#{body.inspect}"
      response = HTTPClient.new.post(request_url, [body].to_json, timeout: api_request_timeout)
      logger.debug "#{response.code}\n#{response.body}"
      resp = JSON.parse(response.body).first
      raise RequestError.new(resp) if RequestError.error_code?(resp)
      resp
    end
  end
end
