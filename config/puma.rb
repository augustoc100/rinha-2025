log_requests false
# Puma configuration for single process and single thread
workers 0
threads 70, 70

port ENV.fetch("PORT") { 4567 }
environment ENV.fetch("RACK_ENV") { "development" }
