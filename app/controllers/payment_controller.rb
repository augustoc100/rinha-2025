
require 'sinatra/base'
require_relative '../model/payment'
require_relative '../use_cases/process_payment'

class PaymentController < Sinatra::Base
    post "/payments" do
      params = JSON.parse request.body.read

      payment_created = ProcessPayment.call(params)
      p "Payment created with ID: #{payment_created.id} attributes #{payment_created.attributes}"

      payment_created.attributes.to_json
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

    where_clause = ""
    params_arr = []
    if from && to
      where_clause = "WHERE requested_at >= ? AND requested_at <= ?"
      params_arr = [from, to]
    end

    sql = <<-SQL
      SELECT processed_by, COUNT(*) AS total_requests, COALESCE(SUM(amount),0) AS total_amount
      FROM payments
      #{where_clause}
      GROUP BY processed_by
    SQL

    def default_result
      {
        totalRequests: 0,
        totalAmount: 0
      }
    end


    grouped = DB[sql, *params_arr].all

    grouped_data = grouped.group_by { it[:processed_by] }
    puts "grouped data"
    puts grouped.inspect
    puts grouped_data

    p grouped_data.inspect

    result = {}
    p "HERE nil #{grouped_data} e #{grouped_data.nil?}  "
    if grouped_data.empty?
      return {
        default: default_result,
        fallback:  default_result
    }.to_json
    end

    %w[default fallback].each do |key|
      group = (grouped_data[key] || []).first
      if  group.nil?
        group = default_result
      end

      result[key] = {
        totalRequests: group[:total_requests],
        totalAmount: group[:total_amount]
      }
    end

    result.to_json
  end

end