# lib/tasks/tenant.rake

require 'pg'

namespace :tenant do
  desc "Create DB and run migrations for a new tenant"
  task create: :environment do
    print "Enter subdomain: "
    subdomain = STDIN.gets.strip

    print "Enter db name: "
    db_name = STDIN.gets.strip

    tenant = Tenant.create!(
      subdomain: subdomain,
      db_name: db_name,
      db_username: 'postgres',
      db_password: 'password'
    )

    puts "Checking if database #{db_name} exists..."

    begin
      conn = PG.connect(dbname: 'postgres', user: 'postgres', password: 'password')
      result = conn.exec("SELECT 1 FROM pg_database WHERE datname='#{db_name}'")

      if result.ntuples == 0
        puts "Creating database #{db_name}..."
        conn.exec("CREATE DATABASE #{db_name}")
      else
        puts "Database #{db_name} already exists, skipping creation."
      end
    ensure
      conn.close if conn
    end

    puts "Running migrations on #{db_name}..."
    ENV['DB_NAME'] = db_name
    Rake::Task["db:migrate"].reenable
    Rake::Task["db:migrate"].invoke

    puts "Tenant #{tenant.subdomain} setup complete!"
  end
end
