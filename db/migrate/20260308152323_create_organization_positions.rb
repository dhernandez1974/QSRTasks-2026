class CreateOrganizationPositions < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_positions, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :department, null: false, foreign_key: { to_table: :organization_departments }, type: :uuid
      t.references :updated_by, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.string :name, null: false
      t.string :rate_type, default: "Hourly"
      t.boolean :maintenance_team, default: false
      t.boolean :maintenance_lead, default: false
      t.references :reports_to, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :jtc
      t.string :authorization_level, default: "Position"
      t.jsonb :authorized, default: {}
      t.string :job_tier, default: "Self"
      t.string :job_class, default: "Crew"

      t.timestamps
    end
  end
end
