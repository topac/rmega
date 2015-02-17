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
      http.use_ssl = true if uri.scheme == 'https'
      apply_http_options(http)
      return http.request(req)
    end

    def apply_http_options(http)
      http.proxy_from_env = false if options.http_proxy_address

      options.marshal_dump.each do |name, value|
        setter_method = name.to_s.split('http_')[1]
        http.__send__("#{setter_method}=", value) if setter_method and value
      end
    end

    def cut_string(string, max = 50)
      string.size <= max ? string : string[0..max-1]+"..."
    end
  end
end