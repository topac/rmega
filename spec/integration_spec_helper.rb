require 'spec_helper'
require "yaml"


def account_file_path
  File.join File.dirname(__FILE__), 'integration/rmega_account.yml'
end

def account_file_exists?
  File.exists? account_file_path
end

def valid_account
  @valid_account ||= YAML.load_file account_file_path
end
