require 'ostruct'

module Rmega
  def self.default_options
    {
      upload_timeout:       120,
      api_request_timeout:  20,
      api_url:              'https://eu.api.mega.co.nz/cs'
    }
  end

  def self.options
    @options ||= OpenStruct.new(default_options)
  end
end
