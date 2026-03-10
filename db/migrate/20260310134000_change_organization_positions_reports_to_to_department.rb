class ChangeOrganizationPositionsReportsToToDepartment < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :organization_positions, column: :reports_to_id
    
    # Change column to allow NULL, then nullify existing records.
    # Existing values point to User records and would violate the new foreign key.
    change_column_null :organization_positions, :reports_to_id, true
    execute "UPDATE organization_positions SET reports_to_id = NULL"

    add_foreign_key :organization_positions, :organization_departments, column: :reports_to_id
  end
end
