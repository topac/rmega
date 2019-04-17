module Rmega
  class ServerError < StandardError
  end

  class TemporaryServerError < StandardError
  end

  class BandwidthLimitExceeded < StandardError
    def initialize(*args)
      if args.any?
        super
      else
        super("Transfer quota exceeded")
      end
    end
  end
end
