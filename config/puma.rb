# Puma configuration for single process and single thread
workers 0
threads 10, 10

port ENV.fetch("PORT") { 4567 }
environment ENV.fetch("RACK_ENV") { "development" }
