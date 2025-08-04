require 'redis'
#REDIS = foo =  Redis.new(url: 'redis://localhost:6379/0')


def get_redis_connection
p "Configuring Redis connection"

url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
p "REDIS URL: #{url}"
  Redis.new(
  url: url,
  connect_timeout: 5, # segundos
  read_timeout: 5,    # segundos
  write_timeout: 5    # segundos
  )
end

REDIS = get_redis_connection