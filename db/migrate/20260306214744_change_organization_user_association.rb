class ChangeOrganizationUserAssociation < ActiveRecord::Migration[8.1]
  def change
    remove_reference :organizations, :contact, foreign_key: { to_table: :users }
    add_reference :users, :organization, foreign_key: true
  end
end
