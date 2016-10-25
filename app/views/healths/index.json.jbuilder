json.array!(@healths) do |health|
  json.extract! health, :id
  json.url health_url(health, format: :json)
end
