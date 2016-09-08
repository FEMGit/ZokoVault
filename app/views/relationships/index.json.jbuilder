json.array!(@relationships) do |relationship|
  json.extract! relationship, :id, :name, :type
  json.url relationship_url(relationship, format: :json)
end
