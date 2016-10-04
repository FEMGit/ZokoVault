json.array!(@vault_entries) do |vault_entry|
  json.extract! vault_entry, :id
  json.url vault_entry_url(vault_entry, format: :json)
end
