
# Puma otimizado para 1 CPU: 1 worker, 16 threads
log_requests false
workers 1
threads 20, 20

port ENV.fetch("PORT") { 4567 }
environment ENV.fetch("RACK_ENV") { "development" }
