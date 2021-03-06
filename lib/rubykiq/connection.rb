require 'redis'
require 'redis/namespace'

module Rubykiq
  class Connection
    extend Forwardable
    def_delegators :@redis_connection, :multi, :namespace, :sadd, :zadd, :lpush, :lpop, :lrange, :llen, :zcard, :zrange, :flushdb
    def_delegators :@redis_client, :host, :port, :db, :password

    # Initialize a new Connection object
    #
    # @param options [Hash]
    def initialize(options = {})
      url = options.delete(:url) { determine_redis_provider }
      namespace = options.delete(:namespace)
      driver = options.delete(:driver)
      @redis_connection ||= build_conection(url, namespace, driver)
      @redis_client ||= @redis_connection.client
      @redis_connection
    end

    private

    # lets try and fallback to another redis url
    def determine_redis_provider
      ENV['REDISTOGO_URL'] || ENV['REDIS_PROVIDER'] || ENV['REDIS_URL'] || 'redis://localhost:6379/0'
    end

    # construct a namespaced redis connection
    def build_conection(url, namespace, driver)
      client = ::Redis.new(url: url, driver: driver)
      ::Redis::Namespace.new(namespace, redis: client)
    end
  end
end
