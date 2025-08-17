class Workers
  PAYMENTS_QUEUE = 'payments_queue'
  def self.configure_workers(queue_name: PAYMENTS_QUEUE, worker_count: 5, callback:)
    workers = []

    worker_count.times do |i|
      workers << Thread.new do
        loop do
          begin 

          _queue_name, payment_data = Queue.pop(queue_name, 2) # timeout de 2 segundos
   
          callback.call(payment_data)
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