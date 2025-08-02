require 'net/http'
require 'json'

port = ENV['PORT'] || 3000
qtd = ENV['QTD'] || 1
sleep_in_milliseconds = ENV['SLEEP'] || 0.5

p "PORT"
p port
qtd.to_i.times do |i|
  sleep sleep_in_milliseconds.to_f
  p "processing request #{i + 1}"
  correlation_id = SecureRandom.uuid
  amount = rand (100..1000)
  uri = URI("http://localhost:#{port}/payments")
  body = {"correlationId" => correlation_id, "amount" => amount}

  http = Net::HTTP.new(uri.host, uri.port)
  request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' => 'application/json'})
  request.body = body.to_json
  response = http.request(request)
  puts response.body
end
