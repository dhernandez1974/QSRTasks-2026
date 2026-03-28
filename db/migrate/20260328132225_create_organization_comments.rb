class CreateOrganizationComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :location, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :order_point, default: "Not Disclosed", null: false
      t.string :pickup_point, default: "Not Disclosed", null: false
      t.boolean :parent, default: true
      t.string :case_number, null: false
      t.string :parent_case_number, null: false
      t.string :case_origin, default: "Not Disclosed", null: false
      t.time :visit_time
      t.date :visit_date
      t.text :customer_comments, null: false
      t.string :issue_category, null: false
      t.string :issue_reason, null: false
      t.string :issue_subcode, null: false
      t.boolean :propel, default: true
      t.string :comment_type, null: false
      t.references :employee_named, null: true, foreign_key: { to_table: :users }, type: :uuid
      t.string :status, default: "Open"
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :source

      t.timestamps
    end
  end
end
