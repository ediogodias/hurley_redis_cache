module HurleyCache
  class Redis
    attr_reader :connection
    attr_reader :redis_url
    attr_reader :redis
    attr_reader :ttl

    def initialize(connection, options = {})
      @connection = connection
      @redis_url = options[:redis_url] || ENV.fetch('REDIS_URL') || 'redis://127.0.0.1:6379/0'
      @redis = options[:redis] || ::Redis.new(url: redis_url)
      @ttl = options[:ttl] || 20.seconds
    end

    def call(request)
      key = key(cache_by(request))

      value = redis.get(key)
      return build_response(value) if value

      response = connection.call(request)
      redis.setex(key, ttl, response.body)
      response
    end

    def cacheable?(request)
      true
    end

    def cache_by(request)
      Rack::Utils.parse_query request.query_string
    end

    def key(hash)
      hash.hash
    end

    def build_response(result)
      Response.new(status_code: 200, body: result)
    end

    class Response
      attr_accessor :status_code, :body, :via

      def intialize(status_code:, body:)
        @status_code = status_code
        @body = body
      end

      def automatically_redirect?(_)
        false
      end
    end
  end
end
