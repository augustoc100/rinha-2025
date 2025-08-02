require_relative '../infra/payment_gateway/payment_gateway_client'

class ProcessPayment
  def self.call(payment_data)
    # Here you would implement the logic to process the payment
    # For example, you might interact with a payment gateway API
    # Simulate a successful payment processing

    p "ProcessPayment"
    puts payment_data
      puts 'params \n'

      payment = Payment.new(
        correlation_id: payment_data["correlationId"],
        amount: payment_data["amount"]
      )

      result = process_payment(payment)

      payment.processed_by = result[:processor_type]
      payment.requested_at = result[:requested_at]

      p "result"
      p result
      # p "Payment created with ID: #{payment_created.attributes}"

       payment.save
       payment
  end

  def self.process_payment(payment)
    begin 
     PaymentGatewayClient.process(DefaultGatewayClient, payment)

    rescue GatewayError, Socket::ResolutionError => e
      p "GatewayError: #{e.message}"
      PaymentGatewayClient.process(FallbackGatewayClient, payment)
    end
  end
end