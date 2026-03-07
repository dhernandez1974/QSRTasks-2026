class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :eid, null: false
      t.string :street, null: false
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.references :contact, null: false, foreign_key: { to_table: :users }
      t.boolean :primary_operator, null: false, default: true

      t.timestamps
    end
  end
end
