require 'redis'
#REDIS = foo =  Redis.new(url: 'redis://localhost:6379/0')

# REDIS = 
def get_redis_connection
# p "Configuring Redis connection"

# p "REDIS URL: #{url}"
# url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
#   Redis.new(
#   url: url,
#   connect_timeout: 5, # segundos
#   read_timeout: 5,    # segundos
#   write_timeout: 5    # segundos
#   )

Redis.new(
  url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
  connect_timeout: 5,
  read_timeout: 5,
  write_timeout: 5
)

end