class CreateDatapassEmployeeHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_employee_histories, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.date :organization_start_date
      t.date :termination_date
      t.date :orientation_date
      t.date :company_service_date
      t.date :review_due_date
      t.date :follow_up_orientation_date
      t.date :termination_entry_date
      t.string :termination_reason
      t.string :termination_code
      t.string :geid
      t.jsonb :store_history
      t.jsonb :repeating_full_jtc_history

      t.timestamps
    end
  end
end
