class CreateHrSsns < ActiveRecord::Migration[8.1]
  def change
    create_table :hr_ssns do |t|
      t.string :geid, null: false
      t.string :ssn, null: false

      t.timestamps
    end
  end
end
