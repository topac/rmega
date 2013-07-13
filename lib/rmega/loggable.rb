require 'logger'

module Rmega
  module Loggable
    def logger
      @@logger ||= begin
        Logger.new($stdout).tap do |l|
          l.formatter = Proc.new { | severity, time, progname, msg| "#{msg}\n" }
          l.level = Logger::ERROR
        end
      end
    end

    def self.included(base)
      base.send(:extend, self)
    end
  end
end
