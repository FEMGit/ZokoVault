json.array!(@power_of_attorneys) do |power_of_attorney|
  json.extract! power_of_attorney, :id
  json.url power_of_attorney_url(power_of_attorney, format: :json)
end
