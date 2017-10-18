module HurleyCache
  class Redis
    attr_accessor :connection

    def initialize(connection)
      @connection = connection
    end

    def call(request)
      raise request.inspect
    end
  end
end
