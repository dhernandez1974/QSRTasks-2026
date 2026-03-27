class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.integer :number, null: false
      t.string :name, null: false
      t.string :street, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.string :phone, null: false
      t.string :email, null: false
      t.integer :safe_count, null: false
      t.integer :headset_count, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end
  end
end
