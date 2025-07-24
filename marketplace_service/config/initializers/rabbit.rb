require 'bunny'


RABBIT_CONNECTION = Bunny.new(
  host: "localhost",
  port: 5672,
  user: "guest",
  password: "guest"
)


begin
  RABBIT_CONNECTION.start
  puts "✅ Connected to RabbitMQ"
rescue Bunny::TCPConnectionFailed => e
  puts "❌ RabbitMQ connection failed: #{e.message}"
end
