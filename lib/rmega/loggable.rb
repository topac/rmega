module Rmega
  module Loggable
    def logger
      @@logger ||= begin
        logger = Logger.new $stdout
        logger.formatter = Proc.new { | severity, time, progname, msg| "#{msg}\n" }
        logger.level = Logger::ERROR
        logger
      end
    end

    def self.included(base)
      base.send :extend, self
    end
  end
end
