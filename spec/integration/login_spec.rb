require 'integration_spec_helper'

describe 'Login' do

  if account_file_exists?

    context 'when email and password are correct' do
      it 'returns a Storage object' do
        expect(login).to respond_to :nodes
      end
    end

    context 'when email and password are invalid' do
      it 'raises an error' do
        expect { Rmega.login('a@apple.com', 'b') }.to raise_error(Rmega::RequestError)
      end
    end
  end
end
