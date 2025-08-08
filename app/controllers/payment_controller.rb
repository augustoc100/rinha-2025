
require 'sinatra/base'
require_relative '../model/payment'
require_relative '../model/queries/get_payment_summary'
require_relative '../use_cases/process_payment'

class PaymentController < Sinatra::Base
  configure do
    set :logging, false
  end
    post "/payments" do
      # p "POST payment"
      params = JSON.parse request.body.read

      ProcessPayment.call(params)

      status 200
  end

  get "/payments-count" do

    dataset = Payment.dataset

    {
      count: dataset.count
    }
  end

  post "/purge-payments" do
    dataset = Payment.dataset
    count = dataset.count
    p "count"
    p count
    dataset.delete

    {
      purged_payments: count
  }.to_json
  end

  get "/payments-summary" do
    from = params["from"]
    to = params["to"]

    puts "get the payments for the dates #{from} #{to}"

    result = GetPaymentSummary.call(from: from, to: to)

    p "result"
    p result
    
    result.to_json
  end

end