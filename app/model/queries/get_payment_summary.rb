class GetPaymentSummary

    def self.default_result
      {
        total_requests: 0,
        total_amount: 0
    }
    end


  def self.call(from:, to:)
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

    grouped = DB[sql, *params_arr].all

     p "grouepd #{grouped}"
     p "DB #{DB}"
    grouped_data = grouped.group_by { it[:processed_by] }

    p grouped_data.inspect

 %w[default fallback].reduce({}) do |result, key|
      group = (grouped_data[key] || []).first
      if  group.nil?
        group = self.default_result
      end

      result[key] = {
        totalRequests: group[:total_requests].round(1),
        totalAmount: group[:total_amount].round(1)
      }
      result
    end
  end
end