# Gem with ruby 1.9+
require "openssl"
require "json"
require "logger"
require "ostruct"

# Gems in the bundle
require "httpclient"
require "execjs"
require "ruby-progressbar"

# Require all the other files
require "rmega/version"
require "rmega/utils"
require "rmega/crypto/rsa"
require "rmega/crypto/aes"
require "rmega/crypto/aes_ctr"
require "rmega/crypto/crypto"
require "rmega/storage"
require "rmega/node"
require "rmega/session"
require "rmega/api_request_error"

module Rmega
  def self.logger
    @logger ||= begin
      logger = Logger.new $stdout
      logger.formatter = Proc.new { | severity, time, progname, msg| "#{msg}\n" }
      logger.level = Logger::INFO
      logger
    end
  end

  def self.login email, password
    session = Session.new email, password
    session.storage
  end

  def self.default_options
    {
      show_progress:        true,
      upload_timeout:       120,
      api_request_timeout:  20,
      api_url:              'https://eu.api.mega.co.nz/cs'
    }
  end

  def self.options
    @options ||= OpenStruct.new default_options
  end
end
