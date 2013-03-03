# encoding: utf-8
require 'integration_spec_helper'

describe 'Login process' do
  if account_file_exists?
    context 'when email and password are correct' do
      it 'returns a valid object' do
        object = Rmega.login valid_account['email'], valid_account['password']
        object.should respond_to :nodes
      end
    end

    context 'when email and password are invalid' do
      it 'raises an error' do
        lambda { Rmega.login 'a@apple.com', 'b' }.should raise_error(Rmega::ApiRequestError)
      end
    end
  end
end
