module Rmega
  module Net
    include Loggable
    include Options

    def survive(retries = options.max_retries, &block)
      yield
    rescue ServerError
      raise
    rescue Exception => error
      retries -= 1
      raise(error) if retries < 0
      logger.debug("[#{error.class}] #{error.message}. #{retries} attempt(s) left.")
      sleep(options.retry_interval)
      retry
    end

    def http_get_content(url)
      uri = URI(url)
      req = ::Net::HTTP::Get.new(uri.request_uri)
      return send_http_request(uri, req).body
    end

    def http_post(url, data)
      uri = URI(url)
      req = ::Net::HTTP::Post.new(uri.request_uri)
      req.body = data
      logger.debug("REQ POST #{url} #{cut_string(data)}")
      response = send_http_request(uri, req)
      logger.debug("REP #{response.code} #{cut_string(response.body)}")
      return response
    end

    private

    def send_http_request(uri, req)
      http = ::Net::HTTP.new(uri.host, uri.port)
      apply_http_options(http)
      http.use_ssl = true if uri.scheme == 'https'
      return http.request(req)
    end

    def apply_http_options(http)
      options.http.each do |name, value|
        http.__send__("#{name}=", value)
      end
    end

    def cut_string(string, max = 50)
      string.size <= max ? string : string[0..max-1]+"..."
    end
  end
end