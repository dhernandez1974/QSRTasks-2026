class AddIndexToOrganizationsEid < ActiveRecord::Migration[8.1]
  def change
    add_index :organizations, :eid
  end
end
