namespace :tenants do
    desc "Run migrations for all tenants"
    task migrate: :environment do
      Tenant.all.each do |tenant|
        puts "\n🔄 Migrating tenant: #{tenant.subdomain} (DB: #{tenant.db_name})"

        begin
          TenantSwitcher.establish_connection_for(tenant)

          ActiveRecord::MigrationContext.new("db/migrate").migrate

          puts "✅ Migration successful for #{tenant.subdomain}"
        rescue => e
          puts "❌ Migration failed for #{tenant.subdomain}: #{e.message}"
        ensure
          ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration[Rails.env])
        end
      end
    end
  end
