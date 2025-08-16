class Queue
  def self.push(queue_name, item)
    begin
      get_redis_connection.with { |conn| conn.lpush(queue_name, item) }
    rescue => e
      warn "[Queue.push] Erro ao adicionar na fila '#{queue_name}': #{e.class} - #{e.message}"
      warn e.backtrace.join("\n")
      raise
    end
  end

  def self.pop(queue_name, timeout)
    begin
      get_redis_connection.with { |conn| conn.brpop(queue_name, timeout) }
    rescue => e
      warn "[Queue.pop] Erro ao buscar da fila '#{queue_name}': #{e.class} - #{e.message}"
      warn e.backtrace.join("\n")
      raise
    end
  end
end