class ChangeLocationIdToOptionalInUsers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :users, :location_id, true
  end
end
