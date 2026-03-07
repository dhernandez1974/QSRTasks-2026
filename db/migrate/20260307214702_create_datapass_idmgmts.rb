class CreateDatapassIdmgmts < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_idmgmts, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.string :country
      t.string :gerid
      t.string :glin
      t.string :nsn
      t.date :modified
      t.string :first_name
      t.string :last_name
      t.string :middle_initial
      t.string :email
      t.date :organization_start_date
      t.date :organization_termination_date
      t.string :termination_code
      t.string :payroll_id
      t.string :geid
      t.jsonb :matching_criteria
      t.jsonb :shares
      t.jsonb :jtcs
      t.jsonb :phones

      t.timestamps
    end
  end
end
