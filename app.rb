
require 'sinatra'

require_relative './app/infra/redis'
require_relative './app/db/setup'
require_relative './app/controllers/controllers'

require_relative './app/use_cases/process_payment'

Thread.new { ProcessPayment.configure_workers }

# Configurar Sinatra para aceitar conexões externas
set :bind, '0.0.0.0'
# set :port, 4567
get '/redis_health' do
  p "redis health"
  begin
    status = REDIS.ping == 'PONG' ? 'UP' : 'DOWN'
    code = status == 'UP' ? 200 : 500
    [code, { status: status, redis_url: ENV['REDIS_URL'] }.to_json]
  rescue => e
    [500, { status: 'DOWN', error: e.message, redis_url: ENV['REDIS_URL'] }.to_json]
  end
end

get '/' do
  {foo: 'bar', app_instance: ENV['APP_INSTANCE']}.to_json
end

get '/bar' do
  # create a dataset from the items table
  items = DB[:items]

  # Use different random strings for the name field
  require 'securerandom'
  if items.count < 20
    3.times do
      items.insert(name: SecureRandom.hex(10), price: rand * 100)
    end
  end

  {
    app_instance: ENV['APP_INSTANCE'],
    items: items.all.to_json
  }.to_json
end


get '/health' do
  {
    status: 'UP',
    app_instance: ENV['APP_INSTANCE']
  }.to_json
end


get '/tables' do
  {
    tables: DB.tables
  }.to_json
end

get '/tables/:table_name' do
  table_name = params[:table_name].to_sym
  if DB.tables.include?(table_name)
    {
      columns: DB[table_name].columns
    }.to_json
  else
    status 404
    {
      error: "Table not found"
    }.to_json
  end
end