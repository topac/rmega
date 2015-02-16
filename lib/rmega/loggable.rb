module Rmega
  def self.logger
    @logger ||= begin
      logger = Logger.new($stdout)
      logger.level = Logger::ERROR
      logger
    end
  end

  module Loggable
    extend ActiveSupport::Concern

    def logger
      Rmega.logger
    end

    module ClassMethods
      def logger
        Rmega.logger
      end
    end
  end
end
