require "openssl"
require "httpclient"
require "execjs"
require "ruby-progressbar"
require "json"
require "logger"
require "rmega/version"
require "rmega/utils"
require "rmega/crypto/rsa"
require "rmega/crypto/aes"
require "rmega/crypto/aes_ctr"
require "rmega/crypto/crypto"
require "rmega/node"
require "rmega/session"

module Rmega
  def self.logger
    @logger ||= begin
      logger = Logger.new $stdout
      logger.formatter = Proc.new { | severity, time, progname, msg| "#{msg}\n" }
      logger.level = Logger::INFO
      logger
    end
  end

  def self.create_session email, password_str
    @current_session = Session.new email, password_str
  end

  def self.current_session
    @current_session
  end
end
