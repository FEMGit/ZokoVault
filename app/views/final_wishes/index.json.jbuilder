json.array!(@final_wishes) do |final_wish|
  json.extract! final_wish, :id, :document_id, :user_id, :primary_contact_id, :notes, :group
  json.url final_wish_url(final_wish, format: :json)
end
