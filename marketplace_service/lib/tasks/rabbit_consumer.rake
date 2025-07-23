# In lib/tasks/rabbit_consumer.rake
namespace :rabbitmq do
    desc "Start RabbitMQ consumer"
    task consume: :environment do
      RabbitMQ::ConsumerWorker.start("product_bought_queue")
      sleep
    end
  end
