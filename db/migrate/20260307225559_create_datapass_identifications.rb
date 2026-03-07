class CreateDatapassIdentifications < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_identifications, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.string :geid
      t.string :first_name
      t.string :nickname
      t.string :last_initial
      t.string :primary_time_card
      t.string :secondary_time_card
      t.string :home_store_nsn
      t.string :unique_id
      t.date :birth_day
      t.string :ssn
      t.string :email_address
      t.string :zip_code
      t.string :ethnicity
      t.string :gender
      t.jsonb :emp_job_title_history

      t.timestamps
    end
  end
end
