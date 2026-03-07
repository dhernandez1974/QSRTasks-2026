class CreateDatapassEmployeeDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_employee_details, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.string :primary_store_nsn
      t.string :gerid
      t.string :payroll_id
      t.string :geid
      t.string :eid
      t.string :first_name
      t.string :last_name
      t.string :nick_name
      t.string :primary_phone
      t.string :birth_date
      t.string :email
      t.string :jtc
      t.string :primary_job_title
      t.string :secondary_jtc
      t.string :secondary_job_title
      t.string :employee_status
      t.string :reason
      t.date :organization_start_date
      t.date :organization_termination_date
      t.date :orientation_date
      t.date :first_punch_date
      t.float :trailing_7_days_actual_hours_worked
      t.float :trailing_4_weeks_actual_hours_worked
      t.string :crew_trainer_trained
      t.date :crew_trainer_trained_date
      t.string :shift_manager_trained
      t.date :shift_manager_trained_date
      t.string :hu_graduate
      t.date :graduation_date
      t.date :current_role_promotion_date
      t.jsonb :shared_stores

      t.timestamps
    end
  end
end
