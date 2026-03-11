class RemovePrimaryFieldsFromOrganizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :organizations, :primary_eid, :string
    remove_column :organizations, :primary_operator, :boolean
    add_column :organizations, :secondary_eids, :jsonb, default: []
  end
end
