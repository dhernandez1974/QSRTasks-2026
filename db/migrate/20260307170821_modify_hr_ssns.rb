class ModifyHrSsns < ActiveRecord::Migration[8.1]
  def change
    rename_column :hr_ssns, :geid, :eid
    add_reference :hr_ssns, :organization, null: false, foreign_key: true
    add_index :hr_ssns, :eid
  end
end
