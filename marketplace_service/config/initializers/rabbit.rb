require 'bunny'


RABBIT_CONNECTION = Bunny.new(
  host: ENV.fetch("RABBITMQ_HOST", "rabbitmq"),
  port: ENV.fetch("RABBITMQ_PORT", 5672).to_i,
  username: ENV.fetch("RABBITMQ_USER", "guest"),
  password: ENV.fetch("RABBITMQ_PASSWORD", "guest")
)


begin
  RABBIT_CONNECTION.start
  puts "✅ Connected to RabbitMQ"
rescue Bunny::TCPConnectionFailed => e
  puts "❌ RabbitMQ connection failed: #{e.message}"
end
