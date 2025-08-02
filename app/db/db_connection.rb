require 'sequel'
require 'logger'

require_relative 'tables'

def connect_with_retry
  retries = 0
  max_retries = 15
  begin
    return Sequel.connect(ENV['DATABASE_URL'] || 'postgres://postgres:postgres@localhost:5432/postgres')
  rescue Sequel::DatabaseConnectionError, PG::ConnectionBad => e
    retries += 1
    puts "Database not ready, retrying (\e[33m#{retries}\e[0m/#{max_retries})..."
    sleep 2
    retry if retries < max_retries
    puts "\e[31mFailed to connect to database after #{max_retries} attempts.\e[0m"
    raise e
  end
end

DB = connect_with_retry

define_tables