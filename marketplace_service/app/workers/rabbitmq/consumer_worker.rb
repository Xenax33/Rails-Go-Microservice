module RabbitMQ
    class ConsumerWorker
      def self.start(queue_name)
        Thread.new do
          channel = RABBITMQ.create_channel
          queue = channel.queue(queue_name, durable: true)

          puts "👂 Listening to queue: #{queue_name}"

          queue.subscribe(block: true) do |_delivery_info, _properties, body|
            payload = JSON.parse(body)
            puts "📥 Received message: #{payload.inspect}"

            MessageHandler.process(payload)
          end
        end
      end
    end
  end
