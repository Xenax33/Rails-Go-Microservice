# app/services/tenant_switcher.rb
class TenantSwitcher
    def self.establish_connection_for(tenant)
        Rails.logger.info "Switched to DB: #{tenant.db_name}"
      config = {
        adapter:  'postgresql',
        encoding: 'unicode',
        pool:     ENV.fetch("RAILS_MAX_THREADS") { 5 },
        database: tenant.db_name,
        username: 'postgres',
        password: 'password',
        host:     'localhost'
      }

      ActiveRecord::Base.establish_connection(config)
    end
  end
