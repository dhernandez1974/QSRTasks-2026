class CreateDatapassHrPersonals < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_hr_personals, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.string :geid
      t.string :first_name
      t.string :last_name
      t.string :middle_initial
      t.string :nickname
      t.date :date_of_birth
      t.string :street_address
      t.string :apt_number
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :home_phone_number
      t.string :cell_phone_number
      t.string :email_address
      t.string :payroll_id
      t.string :personal_marital_status
      t.string :gender
      t.string :national_origin
      t.string :student_status
      t.date :student_permit_expiration_date
      t.string :military_vateran_status
      t.string :veteran_type
      t.string :disabled_veteran
      t.string :emergency_contact_first_name
      t.string :emergency_contact_last_name
      t.string :emergency_contact_home_phone_number
      t.string :emergency_contact_cell_phone_number
      t.string :emergency_contact_work_phone_number
      t.string :primary_time_card
      t.string :secondary_time_card
      t.string :unique_id

      t.timestamps
    end
  end
end
