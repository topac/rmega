module Rmega
  class ServerError < StandardError
  end

  class TemporaryServerError < ServerError
  end
end
