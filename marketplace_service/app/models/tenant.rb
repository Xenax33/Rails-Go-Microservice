class Tenant < ApplicationRecord
    after_create :create_database

    def create_database
      system("createdb -U #{db_username} #{db_name}")
      system("psql -U #{db_username} -d #{db_name} -f db/structure.sql")
    end
end
