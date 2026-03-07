class ConvertTablesToUuid < ActiveRecord::Migration[8.1]
  def up
    # 1. Organizations
    add_column :organizations, :uuid, :uuid, default: "gen_random_uuid()", null: false
    
    # 2. Locations
    add_column :locations, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :locations, :organization_uuid, :uuid

    # 3. Users
    add_column :users, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :users, :organization_uuid, :uuid
    add_column :users, :location_uuid, :uuid

    # 4. Admins
    add_column :admins, :uuid, :uuid, default: "gen_random_uuid()", null: false

    # 5. HrSsns
    add_column :hr_ssns, :uuid, :uuid, default: "gen_random_uuid()", null: false
    add_column :hr_ssns, :organization_uuid, :uuid

    # 6. InboundWebhooks
    add_column :inbound_webhooks, :uuid, :uuid, default: "gen_random_uuid()", null: false

    # 7. locations_users (join table)
    add_column :locations_users, :location_uuid, :uuid
    add_column :locations_users, :user_uuid, :uuid

    # Populate UUID foreign keys
    execute <<-SQL
      UPDATE locations SET organization_uuid = (SELECT uuid FROM organizations WHERE organizations.id = locations.organization_id);
      UPDATE users SET organization_uuid = (SELECT uuid FROM organizations WHERE organizations.id = users.organization_id);
      UPDATE users SET location_uuid = (SELECT uuid FROM locations WHERE locations.id = users.location_id);
      UPDATE hr_ssns SET organization_uuid = (SELECT uuid FROM organizations WHERE organizations.id = hr_ssns.organization_id);
      UPDATE locations_users SET location_uuid = (SELECT uuid FROM locations WHERE locations.id = locations_users.location_id);
      UPDATE locations_users SET user_uuid = (SELECT uuid FROM users WHERE users.id = locations_users.user_id);
    SQL

    # Now we swap IDs. This is complex. We'll drop constraints first.
    
    # Drop foreign keys
    remove_foreign_key :locations, :organizations
    remove_foreign_key :users, :organizations
    remove_foreign_key :users, :locations
    remove_foreign_key :hr_ssns, :organizations

    # Drop primary keys and rename columns
    # Organizations
    remove_column :organizations, :id
    rename_column :organizations, :uuid, :id
    execute "ALTER TABLE organizations ADD PRIMARY KEY (id);"

    # Locations
    remove_column :locations, :id
    rename_column :locations, :uuid, :id
    execute "ALTER TABLE locations ADD PRIMARY KEY (id);"
    remove_column :locations, :organization_id
    rename_column :locations, :organization_uuid, :organization_id

    # Users
    remove_column :users, :id
    rename_column :users, :uuid, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
    remove_column :users, :organization_id
    rename_column :users, :organization_uuid, :organization_id
    remove_column :users, :location_id
    rename_column :users, :location_uuid, :location_id

    # Admins
    remove_column :admins, :id
    rename_column :admins, :uuid, :id
    execute "ALTER TABLE admins ADD PRIMARY KEY (id);"

    # HrSsns
    remove_column :hr_ssns, :id
    rename_column :hr_ssns, :uuid, :id
    execute "ALTER TABLE hr_ssns ADD PRIMARY KEY (id);"
    remove_column :hr_ssns, :organization_id
    rename_column :hr_ssns, :organization_uuid, :organization_id

    # InboundWebhooks
    remove_column :inbound_webhooks, :id
    rename_column :inbound_webhooks, :uuid, :id
    execute "ALTER TABLE inbound_webhooks ADD PRIMARY KEY (id);"

    # locations_users
    remove_column :locations_users, :location_id
    rename_column :locations_users, :location_uuid, :location_id
    remove_column :locations_users, :user_id
    rename_column :locations_users, :user_uuid, :user_id

    # Add foreign keys back
    add_foreign_key :locations, :organizations
    add_foreign_key :users, :organizations
    add_foreign_key :users, :locations
    add_foreign_key :hr_ssns, :organizations
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
