# lib/middleware/tenant_middleware.rb
module Middleware
    class TenantMiddleware
      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)
        subdomain = request.host.split('.').first
        tenant = Tenant.find_by(subdomain: subdomain)

        if tenant
          TenantSwitcher.establish_connection_for(tenant)
        else
          return [404, {}, ["Tenant not found"]]
        end

        @app.call(env)
      ensure
        ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration[Rails.env])
      end
    end
  end
