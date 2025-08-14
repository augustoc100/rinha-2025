class GatewayError < StandardError; end

require 'json'
require_relative './../cache'

class PaymentGatewayBase
#   {
#     "failing": false,
#     "minResponseTime": 100
# }

  def self.get_health_data
    health_url = "#{url}/payments/service-health"
    # p health_url
    cache_name = "#{processor_type}_health"

    health = Cache.get(cache_name)
    if health.nil? 
      response = HTTParty.get(health_url, timeout: 5)
      # p "health get new response #{response.parsed_response}"

      result = response.parsed_response
      Cache.set(cache_name, result.to_json, ex: 5)

      result
    else
      # p "health in cache"
      JSON.parse(health)
    end
  end

  def self.health
    !get_health_data["failing"]
  end

  def self.respond_in
    get_health_data["minResponseTime"].to_i
  end

  def self.payment_url
    url = self.url.end_with?('/payments') ? self.url : "#{self.url}/payments"
    url = "http://#{url}" unless url.start_with?('http')
    # p "url"
    # p url
    url
  end

end
class DefaultGatewayClient < PaymentGatewayBase

  def self.url 
      ENV['PROCESSOR_DEFAULT_URL'] || "localhost:8001"
  end

  def self.processor_type
    "default"
  end
end

class FallbackGatewayClient < PaymentGatewayBase
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
    # p "Gateway Health"
    # p gateway.health

    response = HTTParty.post(url, body: body.to_json, headers: { 'Content-Type' => 'application/json' })

    if response.code >= 400
      # p "error at gateway #{gateway.processor_type}"
      # p "HTTP error body: #{response.body}"
      # p "HTTP error message: #{response.message}"
      raise GatewayError, "Payment processing failed at #{gateway.processor_type} gateway"
      # p "error at gateway #{gateway.processor_type}"
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