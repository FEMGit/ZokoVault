json.array!(@lives) do |life|
  json.extract! life, :id
  json.url life_url(life, format: :json)
end
