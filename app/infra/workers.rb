class Workers
  PAYMENTS_QUEUE = 'payments_queue'
  def self.configure_workers(queue_name: PAYMENTS_QUEUE, worker_count: 5, callback:)

  #  p "Configure Workers"
    workers = []

    # p "create the workers for #{queue_name}"
    worker_count.times do |i|
      workers << Thread.new do
        loop do
          begin 
          # p "worker #{i}"
          # p "retrieving data from queue #{queue_name}"
          # _queue_name, payment_data = redis.brpop(queue_name, 2) # timeout de 2 segundos
          _queue_name, payment_data = Queue.pop(queue_name, 2) # timeout de 2 segundos
          # p "get data"
          # p payment_data
          # p "process the payment"
          callback.call(payment_data)
          # process_payment_data(payment_data)
          rescue => e 
              p "Erro no worker #{i}: #{e.message}"
               p e.backtrace
          end
        end
      end
    end
    # workers.each(&:join)
  end
end