class ModifyHrSsns < ActiveRecord::Migration[8.1]
  def change
    add_reference :hr_ssns, :organization, null: false, foreign_key: true
    add_index :hr_ssns, :geid
  end
end
