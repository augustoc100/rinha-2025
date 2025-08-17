# require 'redis'
# #REDIS = foo =  Redis.new(url: 'redis://localhost:6379/0')

# # REDIS = 
# def get_redis_connection
# # p "Configuring Redis connection"

# # p "REDIS URL: #{url}"
# # url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
# #   Redis.new(
# #   url: url,
# #   connect_timeout: 5, # segundos
# #   read_timeout: 5,    # segundos
# #   write_timeout: 5    # segundos
# #   )

# Redis.new(
#   url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
#   connect_timeout: 5,
#   read_timeout: 5,
#   write_timeout: 5
# )

# end


require 'redis'
require 'connection_pool'


# Pool de conexões Redis igual ao total de threads do Puma (16)
REDIS_POOL = ConnectionPool.new(size: 100, timeout: 5) do
  Redis.new(
    url: ENV['REDIS_URL'] || 'redis://localhost:6379/0',
    connect_timeout: 5,
    read_timeout: 5,
    write_timeout: 5
  )
end

def get_redis_connection
  REDIS_POOL
end