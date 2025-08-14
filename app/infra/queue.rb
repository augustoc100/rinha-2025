class Queue
  def self.push(queue_name, item)
    redis = get_redis_connection
    redis.lpush(queue_name, item)
  end

  def self.pop(queue_name, timeout)
    redis = get_redis_connection
    redis.brpop(queue_name, timeout)
  end
end