class GatewayError < StandardError; end

class DefaultGatewayClient
  def self.url 
      ENV['PROCESSOR_DEFAULT_URL'] || "localhost:8001"
  end

  def self.payment_url
    url = self.url.end_with?('/payments') ? self.url : "#{self.url}/payments"
    url = "http://#{url}" unless url.start_with?('http')
    p "url"
    p url
    url
  end

  def self.processor_type
    "default"
  end

  def self.health(times = 1)
    p "health url #{times}"
    health_url = "#{url}/payments/service-health"
    p health_url

    response = HTTParty.get(health_url, timeout: 5)
    p "health"

    result = response.parsed_response

    is_falling = result["failing"] != false
    p "is falling #{is_falling}"
    p is_falling
    result
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
    url = gateway.payment_url

    body = {
      correlationId: payment["correlation_id"],
      amount: payment["amount"],
      requestedAt: DateTime.parse(payment["requested_at"]).iso8601
    }
    # p "url"
    # p url
    # p "body"
    # p body
    p "Gateway Health"
    p gateway.health

    response = HTTParty.post(url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })

    if response.code >= 400
      # p "error at gateway #{gateway.processor_type}"
      # p "HTTP error body: #{response.body}"
      # p "HTTP error message: #{response.message}"
      raise GatewayError, "Payment processing failed at #{gateway.processor_type} gateway"
      # p "error at gateway #{gateway.processor_type}"
      raise GatewayError, "Payment processing failed at #{gateway.processor_type} gateway"
    end

    # p "response"
    # p response
    # p response.parsed_response

    if response.parsed_response.nil?
      return {}
    end

    (response.parsed_response.nil? ? {} : response.parsed_response).merge(processor_type: gateway.processor_type)
  end
end