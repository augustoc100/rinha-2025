class Queue
  def self.push(queue_name, item)
    # p "Pushing item to #{queue_name}: #{item}"
    get_redis_connection.lpush(queue_name, item)
    # p "pushed"
  end

  def self.pop(queue_name, timeout)
     get_redis_connection.brpop(queue_name, timeout)
  end
end