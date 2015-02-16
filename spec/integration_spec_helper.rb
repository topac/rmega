require 'spec_helper'

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
  Dir.tmpdir
end

RSpec.configure do |config|
  config.before(:all) do
    Rmega.options.show_progress = false
    FileUtils.mkdir_p(temp_folder)
  end

  config.after(:all) do
    FileUtils.rm_rf(temp_folder)
  end
end
