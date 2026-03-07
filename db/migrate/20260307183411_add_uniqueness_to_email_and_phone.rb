class AddUniquenessToEmailAndPhone < ActiveRecord::Migration[8.1]
  def change
    add_index :locations, :email, unique: true
    add_index :locations, :phone, unique: true
    add_index :users, :phone_number, unique: true
  end
end
