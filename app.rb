
require 'sinatra'

require_relative './app/infra/redis'
require_relative './app/db/setup'
require_relative './app/controllers/controllers'

require_relative './app/infra/workers'

Thread.new do
   Workers.configure_workers(
      queue_name: Workers::PAYMENTS_QUEUE,
      worker_count: 20,
      callback: ->(payment_data) { ProcessPayment.process_payment_data(payment_data) }
    )
end

set :bind, '0.0.0.0'
set :logging, false
set :logger, nil

get '/health' do
  {
    status: 'UP',
    app_instance: ENV['APP_INSTANCE']
  }.to_json
end