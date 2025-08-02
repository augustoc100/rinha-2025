# require_relative './base_model'

class Payment < Sequel::Model
  def self.table_name 
    :payments
  end

  plugin :timestamps, update_on_create: true

  # def set_validations
  #   assert(:correlation_id,  'is required') { correlation_id.present? }
  #   assert(:amount, 'must be greater than zero') { amount&.positive? }
  # end

  def attributes
    puts "instance variables"
    {
      id: id,
      correlation_id: correlation_id,
      amount: amount,
      processed_by: processed_by,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end