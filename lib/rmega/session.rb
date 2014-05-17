require 'rmega/storage'
require 'rmega/errors'
require 'rmega/crypto/crypto'
require 'rmega/utils'

module Rmega
  def self.login(email, password)
    Session.new(email, password).storage
  end

  class Session
    include Loggable

    attr_reader :email, :request_id, :sid, :master_key, :shared_keys, :rsa_privk

    def initialize(email, password)
      @email = email
      @request_id = random_request_id
      @shared_keys = {}

      login(password)
    end

    def options
      Rmega.options
    end

    delegate :api_url, :api_request_timeout, to: :options
    delegate :max_retries, :retry_interval, to: :options

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
      @rsa_privk = Crypto.decrypt_rsa_privk(@master_key, resp['privk'])
      @sid = Crypto.decrypt_sid(@rsa_privk, resp['csid'])
    end

    def random_request_id
      rand(1E7..1E9).to_i
    end

    def request_url
      "#{api_url}?id=#{@request_id}".tap do |url|
        url << "&sid=#{@sid}" if @sid
      end
    end

    def request(content, retries = max_retries)
      @request_id += 1
      logger.debug "POST #{request_url} #{content.inspect}"

      response = HTTPClient.new.post(request_url, [content].to_json, timeout: api_request_timeout)
      code, body = response.code.to_i, response.body

      logger.debug("#{code} #{body}")

      if code == 500 && body.to_s.empty?
        raise Errors::ServerError.new("Server too busy", temporary: true)
      else
        json = JSON.parse(body).first
        raise Errors::ServerError.new(json) if json.to_s =~ /\A\-\d+\z/
        json
      end
    rescue SocketError, Errors::ServerError => error
      raise(error) if retries < 0
      raise(error) if error.respond_to?(:temporary?) && !error.temporary?
      retries -= 1
      sleep(retry_interval)
      retry
    end
  end
end
