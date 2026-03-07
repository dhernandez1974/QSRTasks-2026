class AddPrimaryEidToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :primary_eid, :string
  end
end
