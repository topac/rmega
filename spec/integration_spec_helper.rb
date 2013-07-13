require 'spec_helper'
require 'yaml'

def account_file_path
  File.join File.dirname(__FILE__), 'integration/rmega_account.yml'
end

def account_file_exists?
  File.exists? account_file_path
end

def account
  @account ||= YAML.load_file account_file_path
end

def login
  Rmega.login(account['email'], account['password'])
end

def temp_folder
  '/tmp/.rmega_spec'
end

RSpec.configure do |config|
  config.before { FileUtils.mkdir_p(temp_folder) }
  config.after { FileUtils.rm_rf(temp_folder) }
end
