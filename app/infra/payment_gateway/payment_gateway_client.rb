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
    url = gateway.url.end_with?('/payments') ? gateway.url : "#{gateway.url}/payments"
    url = "http://#{url}" unless url.start_with?('http')

    body = {
      correlationId: payment["correlation_id"],
      amount: payment["amount"],
      requestedAt: DateTime.parse(payment["requested_at"]).iso8601
    }
    p "url"
    p url
    p "body"
    p body

    response = HTTParty.post(url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })

    if response.code >= 400
      p "error at gateway #{gateway.processor_type}"
      p "HTTP error body: #{response.body}"
      p "HTTP error message: #{response.message}"
      raise GatewayError, "Payment processing failed at #{gateway.processor_type} gateway"
      p "error at gateway #{gateway.processor_type}"
      raise GatewayError, "Payment processing failed at #{gateway.processor_type} gateway"
    end

    p "response"
    p response
    p response.parsed_response

    if response.parsed_response.nil?
      return {}
    end

    (response.parsed_response.nil? ? {} : response.parsed_response).merge(processor_type: gateway.processor_type)
  end
end