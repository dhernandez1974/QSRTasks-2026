class AddDetailsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :birth_date, :date
    add_column :users, :social, :string
    add_column :users, :eid, :string
    add_column :users, :geid, :string
    add_column :users, :payroll_id, :string
    add_column :users, :hire_date, :date
  end
end
