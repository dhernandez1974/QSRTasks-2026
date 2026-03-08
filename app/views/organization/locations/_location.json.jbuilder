json.extract! location, :id, :number, :name, :street, :city, :state, :zip, :phone, :email, :safe_count, :headset_count, :organization_id, :created_at, :updated_at
json.url location_url(location, format: :json)
