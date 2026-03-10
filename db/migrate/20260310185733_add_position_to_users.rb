class AddPositionToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :position_id, :uuid
    add_index :users, :position_id
    add_foreign_key :users, :organization_positions, column: :position_id
  end
end
