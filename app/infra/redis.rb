require 'redis'
#REDIS = foo =  Redis.new(url: 'redis://localhost:6379/0')


def get_redis_connection
# p "Configuring Redis connection"

# p "REDIS URL: #{url}"
url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
  Redis.new(
  url: url,
  connect_timeout: 5, # segundos
  read_timeout: 5,    # segundos
  write_timeout: 5    # segundos
  )
end