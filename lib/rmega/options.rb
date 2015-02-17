module Rmega
  def self.default_options
    {
      thread_pool_size:     4,
      max_retries:          10,
      retry_interval:       3,
      http_open_timeout:    180,
      http_read_timeout:    180,
      # http_proxy_address:   '127.0.0.1',
      # http_proxy_port:      8080,
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
