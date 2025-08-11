require_relative './redis'

class Cache
  def self.redis
    @redis ||= get_redis_connection
  end

  def self.get(key)
    redis.get(key)
  end

  def self.set(key, value, ex: nil)
    redis.set(key, value, ex: ex)
  end
end