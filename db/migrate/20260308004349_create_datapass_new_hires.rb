class CreateDatapassNewHires < ActiveRecord::Migration[8.1]
  def change
    create_table :datapass_new_hires, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.string :mchire_location
      t.date :poll_date
      t.date :created_at_source
      t.string :ds
      t.string :oid
      t.string :a
      t.date :bdt
      t.string :c
      t.string :e
      t.string :fn
      t.string :mn
      t.string :hs
      t.string :nh_id
      t.string :ln
      t.string :p
      t.string :st
      t.string :z
      t.string :jtc
      t.string :job_title
      t.string :r
      t.string :ea_a
      t.string :ea_dt
      t.string :nm
      t.string :ssn

      t.timestamps
    end
  end
end
