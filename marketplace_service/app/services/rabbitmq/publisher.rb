module RabbitMQ
    class Publisher
      def self.publish(queue_name, payload)
        channel = RABBITMQ.create_channel
        queue = channel.queue(queue_name, durable: true)

        queue.publish(payload.to_json, persistent: true)
        channel.close
      end
    end
  end
