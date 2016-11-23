json.array!(@taxes) do |tax|
  json.extract! tax, :id, :document_id, :tax_preparer_id, :notes, :user_id, :tax_year
  json.url tax_url(tax, format: :json)
end
