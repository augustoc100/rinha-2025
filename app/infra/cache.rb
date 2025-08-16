require_relative './redis'

class Cache
  def self.redis
    @redis ||= get_redis_connection
  end

  def self.get(key)
    get_redis_connection.with { |conn| conn.get(key) }
  end

  def self.set(key, value, ex: nil)
    get_redis_connection.with { |conn| conn.set(key, value, ex: ex) }
  end
end