module Rmega
  def self.default_options
    {
      thread_pool_size:     4,
      max_retries:          10,
      retry_interval:       3,
      http: {
        open_timeout:       180,
        read_timeout:       180,
      },
      show_progress:        true,
      api_url:              'https://eu.api.mega.co.nz/cs'
    }
  end

  def self.options
    @options ||= OpenStruct.new(default_options)
  end

  module Options
    extend ActiveSupport::Concern

    def options
      Rmega.options
    end

    module ClassMethods
      def options
        Rmega.options
      end
    end
  end
end
