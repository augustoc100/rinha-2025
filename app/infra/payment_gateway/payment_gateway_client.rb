class GatewayError < StandardError; end

class DefaultGatewayClient
  def self.url 
      ENV['PROCESSOR_DEFAULT_URL'] || "localhost:8001"
  end

  def self.processor_type
    "default"
  end
end

class FallbackGatewayClient
  def self.url
      ENV['PROCESSOR_FALLBACK_URL'] || 'localhost:8002'
  end

  def self.processor_type
    "fallback"
  end
end


require 'httparty'

class PaymentGatewayClient
  def self.process(gateway, payment)
    p "PaymentGatewayClient"
    url = gateway.url.end_with?('/payments') ? gateway.url : "#{gateway.url}/payments"
    url = "http://#{url}" unless url.start_with?('http')

    p "url"
    p url

    body = {
      correlationId: payment.correlation_id,
      amount: payment.amount,
      requestedAt: Time.now.iso8601 
    }
     p "request body"
     p body.to_json
    response = HTTParty.post(url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
     
    p "response"
    p response

    p "response code"
    p response.code
    if response.code >= 500
      p "error at gateway #{gateway.processor_type}"
      raise GatewayError, "Payment processing failed at #{gateway.processor_type} gateway"
    end

    p 'response parsed'
    response_body = response.parsed_response.merge(processor_type: gateway.processor_type, requested_at: body[:requestedAt])
    p response_body
    
    response_body
  end
end