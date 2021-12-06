module Rmega
  module ConnPool
    include Loggable
    include Options
    extend MonitorMixin
    
    # url: URI / String
    # options: any options that Net::HTTP.new accepts
    def self.get(url, options = {})
      uri = url.is_a?(URI) ? url : URI(url)
      connection_manager.get_client(uri, options)
    end
    
    def self.connection_manager
      synchronize do
        @connection_managers ||= []

        # we first clear all old ones
        removed = @connection_managers.reject!(&:stale?)
        (removed || []).each(&:close_connections!)
        
        # get the manager
        Thread.current[:http_connection_manager] ||= self.synchronize do
          manager = ConnectionManager.new
          @connection_managers << manager
          manager
        end
      end
    end
  
    # @see https://www.dmitry-ishkov.com/2021/05/turbocharge-http-requests-in-ruby.html
    class ConnectionManager
      include MonitorMixin
      # if a client wasn't used within this time range
      # it gets removed from the cache and the connection closed.
      # This helps to make sure there are no memory leaks.
      STALE_AFTER = 180
  
      # Seconds to reuse the connection of the previous request. 
      # If the idle time is less than this Keep-Alive Timeout, Net::HTTP reuses the TCP/IP socket used by the previous communication. Source: Ruby docs
      KEEP_ALIVE_TIMEOUT = 300
  
      # KEEP_ALIVE_TIMEOUT vs STALE_AFTER
      # STALE_AFTER - how long an Net::HTTP client object is cached in ruby
      # KEEP_ALIVE_TIMEOUT - how long that client keeps TCP/IP socket open.
  
      attr_accessor :clients_store, :last_used
  
      def initialize(*args)
        super
        self.clients_store = {}
        self.last_used = Time.now
      end
  
      def get_client(uri, options)
        synchronize do
          # refresh the last time a client was used,
          # this prevents the client from becoming stale
          self.last_used = Time.now
  
          # we use params as a cache key for clients.
          # 2 connections to the same host but with different
          # options are going to use different HTTP clients
          params = [uri.host, uri.port, options]
          client = clients_store[params]
  
          return client if client
  
          client = ::Net::HTTP.new(uri.host, uri.port)
          client.keep_alive_timeout = KEEP_ALIVE_TIMEOUT

          # set SSL to true if a scheme is https
          client.use_ssl = uri.scheme == "https"
  
          # open connection
          client.start
  
          # cache the client
          clients_store[params] = client
  
          client
        end
      end
  
      # close connections for each client
      def close_connections!
        synchronize do
          clients_store.values.each(&:finish)
          self.clients_store = {}
        end
      end

      def stale?
        Time.now - last_used > STALE_AFTER
      end
    end
  end
end
