class RabbitPublisher
  def self.buy_product_from_tenant(tenant, product_id)
    channel = RABBIT_CONNECTION.create_channel

    # Create a durable queue for sending requests
    queue = channel.queue("purchase_requests", durable: true)

    # Create a temporary reply queue (auto-delete, exclusive)
    reply_queue = channel.queue('', exclusive: true)

    correlation_id = SecureRandom.uuid

    # Publish the message
    queue.publish(
      { tenant: tenant, product_id: product_id }.to_json,
      routing_key: queue.name,
      correlation_id: correlation_id,
      reply_to: reply_queue.name,
      content_type: 'application/json',
      expiration: 5000 # Set a timeout for the request (5 seconds)
    )

    # Wait for the response
    response = nil
    Timeout.timeout(5) do
      loop do
        delivery_info, properties, payload = reply_queue.pop(manual_ack: true)

        if delivery_info && properties[:correlation_id] == correlation_id
          response = payload
          break
        end

        sleep 0.1
      end
    end

    response
  rescue Timeout::Error
    Rails.logger.error "⏳ Timeout waiting for RabbitMQ response"
    nil
  ensure
    channel.close if channel&.open?
  end
end