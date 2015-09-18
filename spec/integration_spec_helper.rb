require 'spec_helper'

def account_file_path
  File.join(File.dirname(__FILE__), "account.yaml")
end

def account?
  account
end

def account
  if ENV["MEGA_EMAIL"] and ENV["MEGA_PASSWORD"]
    {'email' => ENV["MEGA_EMAIL"], 'password' => ENV["MEGA_PASSWORD"]}
  elsif File.exists?(account_file_path)
    YAML.load_file(account_file_path)
  else
    nil
  end
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
