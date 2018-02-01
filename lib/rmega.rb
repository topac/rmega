require 'thread'
require 'ostruct'
require 'logger'
require 'uri'
require 'net/http'
require 'base64'
require 'openssl'
require 'digest/md5'
require 'json'
require 'securerandom'

# Used only in specs
require 'yaml'
require 'tmpdir'
require 'fileutils'

require 'rmega/version'
require 'rmega/loggable'
require 'rmega/options'
require 'rmega/not_inspectable'
require 'rmega/errors'
require 'rmega/api_response'
require 'rmega/utils'
require 'rmega/net'
require 'rmega/pool'
require 'rmega/progress'
require 'rmega/crypto'
require 'rmega/session'
require 'rmega/storage'
require 'rmega/nodes/factory'

module Rmega
  def self.login(email, password)
    Session.new.login(email, password).storage
  end

  def self.download(public_url, path = Dir.pwd)
    node = Nodes::Factory.build_from_url(public_url)
    return node.download(path)
  end
end
