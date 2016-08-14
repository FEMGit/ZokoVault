json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :category, :group, :name, :webaddress, :phone, :contact_id, :user_id
  json.url vendor_url(vendor, format: :json)
end
