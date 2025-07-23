class CreateTenants < ActiveRecord::Migration[7.2]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :subdomain
      t.string :db_name
      t.string :db_username
      t.string :db_password

      t.timestamps
    end
  end
end
