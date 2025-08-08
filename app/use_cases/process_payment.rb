require_relative '../infra/payment_gateway/payment_gateway_client'
require_relative '../infra/redis'

class ProcessPayment
  QUEUE_PROCESSOR_NAME = 'payments_queue'
  def self.call(payment_data)
    # Here you would implement the logic to process the payment
    # For example, you might interact with a payment gateway API
    # Simulate a successful payment processing

      payment = Payment.new(
        correlation_id: payment_data["correlationId"],
        amount: payment_data["amount"],
        requested_at: Time.now.iso8601
      )

       process_payment(payment)

      # payment.processed_by = result[:processor_type]

      # # p "Payment created with ID: #{payment_created.attributes}"

      #  payment.save
      #  payment
  end

  def self.process_payment(payment)
    # p "payment, #{payment.attributes}"
    redis = get_redis_connection
    # require 'pry' ; binding.pry

     Thread.new do
      begin
    #     p "redis ping"
    #     p redis.ping # Deve imprimir "PONG" se a conexão estiver correta

    #     p "add in test queue"
    #     redis.lpush('test', 'foo')

    # p "adding na fila #{QUEUE_PROCESSOR_NAME}"
        redis.lpush('payments_queue', payment.attributes.to_json)
        #  p "item added"
      rescue => e
        p "Erro ao adicionar na fila: #{e.message}"
        p e.backtrace
      end
    end
    # unless lpush_thread.join(2) # timeout de 2 segundos
    #   p "Timeout ao adicionar na fila"
    # end
  end

  def self.configure_workers(queue_name: QUEUE_PROCESSOR_NAME, worker_count: 5)

    redis = get_redis_connection
  #  p "Configure Workers"
    workers = []

    # p "create the workers for #{queue_name}"
    worker_count.times do |i|
      workers << Thread.new do
        loop do
          begin 
          # p "worker #{i}"
          # p "retrieving data from queue #{queue_name}"
          _queue_name, payment_data = redis.brpop(queue_name, 2) # timeout de 2 segundos
          # p "get data"
          # p payment_data
          # p "process the payment"
          process_payment_data(payment_data)
          rescue => e 
              p "Erro no worker #{i}: #{e.message}"
               p e.backtrace
          end
        end
      end
    end
    # workers.each(&:join)
  end

  def self.process_payment_data(payment_data)
    # Here you would implement the logic to process the payment data
    # For example, you might extract relevant information and call the payment client
    # p 'get payment data'
    # p "json"
    # p payment_data
    # p "hash"
    parsed_data = JSON.parse(payment_data)

    # p "call paymetn client"
    result = call_payment_client(parsed_data)

    # p "save payment parsed #{parsed_data}"
    # p "save payment correlation_id #{parsed_data["correlation_id"]}"

    # p "result #{result}"

    payment = Payment.create(
      correlation_id: parsed_data["correlation_id"],
      amount: parsed_data["amount"],
      requested_at: parsed_data["requested_at"],
      processed_by: result[:processor_type]
    )
    payment.save

    payment
  end

  def self.call_payment_client(payment)
    begin 
     PaymentGatewayClient.process(DefaultGatewayClient, payment)

    rescue GatewayError, Socket::ResolutionError => e
      p "error #{e}"
      PaymentGatewayClient.process(FallbackGatewayClient, payment)
    end
  end
end