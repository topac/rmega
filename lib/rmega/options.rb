require 'ostruct'

module Rmega
  def self.default_options
    {
      upload_timeout:       120,
      max_retries:          10,
      retry_interval:       1,
      api_request_timeout:  20,
      api_url:              'https://eu.api.mega.co.nz/cs'
    }
  end

  def self.options
    @options ||= OpenStruct.new(default_options)
  end
end
