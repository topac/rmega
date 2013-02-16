require "openssl"
require "httparty"
require "execjs"
require "json"
require "logger"
require "rmega/version"
require "rmega/utils"
require "rmega/crypto/rsa"
require "rmega/crypto/aes"
require "rmega/crypto/crypto"
require "rmega/commands"
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
end
