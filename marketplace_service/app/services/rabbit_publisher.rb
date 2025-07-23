class RabbitPublisher
    def self.buy_product_from_tenant(tenant, product_id)
      channel = RABBIT_CONNECTION.create_channel
  
      # Declare the purchase request queue
      queue = channel.queue("purchase_requests", durable: true)
  
      # Set up a temporary reply queue
      reply_queue = channel.queue('', exclusive: true)
  
      correlation_id = SecureRandom.uuid
      response = nil
  
      # Set up the consumer for the reply
      reply_queue.subscribe(block: false) do |_delivery_info, properties, payload|
        if properties.correlation_id == correlation_id
          response = payload
        end
      end
  
      # Publish the request
      queue.publish(
        { tenant: tenant, product_id: product_id }.to_json,
        routing_key: queue.name,
        correlation_id: correlation_id,
        reply_to: reply_queue.name
      )
  
      # Wait (for a max of 5 seconds) for the response
      Timeout.timeout(5) do
        sleep 0.1 until response
      end
  
      response
    rescue Timeout::Error
      Rails.logger.error "⏳ Timeout waiting for RabbitMQ response"
      nil
    ensure
      channel.close if channel&.open?
    end
  end
  