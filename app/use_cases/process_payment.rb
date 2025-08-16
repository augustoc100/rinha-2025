require_relative '../infra/payment_gateway/payment_gateway_client'
require_relative '../infra/redis'
require_relative '../infra/queue'

class ProcessPayment
  def self.call(payment_data)
      payment_data = {
        correlation_id: payment_data["correlationId"],
        amount: payment_data["amount"],
        requested_at: Time.now.iso8601
      }

        Queue.push(Workers::PAYMENTS_QUEUE, payment_data.to_json)
  end

  def self.process_payment_data(payment_data)
    parsed_data = JSON.parse(payment_data)

    gateway_client = get_gateway_client

    gateway_result = nil
    payment = nil

    threads = []
    threads << Thread.new { gateway_result = call_payment_client(gateway_client, parsed_data) }
    threads << Thread.new do 
      sleep(gateway_client.respond_in || 0)

    payment = save_payment(parsed_data, { processor_type: gateway_client.processor_type }) 
    end
    threads.each(&:join)

    if payment && gateway_result && gateway_result[:processor_type] != payment.processed_by
      p "ERROR on processing"
      payment.update(processed_by: gateway_result[:processor_type])
    end

    payment
  end

  def self.save_payment(payment_data, gateway_result)
    payment = Payment.create(
      correlation_id: payment_data["correlation_id"],
      amount: payment_data["amount"],
      requested_at: payment_data["requested_at"],
      processed_by: gateway_result[:processor_type]
    )
    payment.save

    payment
  end

  def self.get_gateway_client
    DefaultGatewayClient.health ? DefaultGatewayClient : FallbackGatewayClient
  end

  def self.call_payment_client(gateway, payment)
    begin
      PaymentGatewayClient.process(gateway, payment)

    rescue GatewayError, Socket::ResolutionError => e
      p "error #{e}"
      PaymentGatewayClient.process(FallbackGatewayClient, payment)
    end
  end
end