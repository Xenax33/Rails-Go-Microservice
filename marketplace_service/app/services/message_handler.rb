class MessageHandler
    def self.process(payload)
      # Example: update a product's sold_qty
      tenant_subdomain = payload["tenant"]
      product_id = payload["product_id"]
  
      tenant = Tenant.find_by(subdomain: tenant_subdomain)
      return unless tenant
  
      TenantSwitcher.establish_connection_for(tenant)
  
      product = Product.find_by(id: product_id)
      product.increment!(:sold_qty)
  
      puts "✅ Updated sold_qty for product #{product_id} in #{tenant_subdomain}"
    ensure
      # Always reset
      ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration[Rails.env])
    end
  end
  