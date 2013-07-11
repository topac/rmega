# Gem with ruby 1.9+
require "openssl"
require "json"
require "logger"
require "ostruct"

# Gems in the bundle
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/string/inflections'
require "httpclient"
require "execjs"
require "ruby-progressbar"

# Require all the other files
require "rmega/version"
require "rmega/loggable"
require "rmega/utils"
require "rmega/crypto/rsa"
require "rmega/crypto/aes"
require "rmega/crypto/aes_ctr"
require "rmega/crypto/crypto"
require "rmega/storage"
require "rmega/node/node"
require "rmega/session"
require "rmega/api_request_error"
require "rmega/pool"
require "rmega/downloader"

module Rmega
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
