class AddIpadCountAndLocationTypeToLocations < ActiveRecord::Migration[8.1]
  def change
    add_column :locations, :ipad_count, :integer
    add_column :locations, :location_type, :string, default: "Traditional"
  end
end
