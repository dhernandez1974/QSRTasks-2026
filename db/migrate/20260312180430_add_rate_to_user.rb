class AddRateToUser < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :rate, :float
  end
end
