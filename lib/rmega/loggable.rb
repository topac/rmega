module Rmega
  module Loggable
    def logger
      Rmega.logger
    end

    def self.included(base)
      base.send :extend, self
    end
  end
end
