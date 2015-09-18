require 'integration_spec_helper'

describe 'Login' do

  if account?

    context 'when email and password are correct' do
      it 'does not raise erorrs' do
        expect { login }.not_to raise_error
      end
    end

    context 'when email and password are invalid' do
      it 'raises an error' do
        expect { Rmega.login('foo', 'bar') }.to raise_error(Rmega::ServerError)
      end
    end
  end
end
