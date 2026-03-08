class CreateOrganizationDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_departments, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.references :updated_by, null: false, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end
  end
end
